//
//  CreateGroupAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

/**
 *  创建讨论组，object为数组，index1:groupName,index2:groupAvatar,index3:userlist
 */
class CreateGroupAPI: DDSuperAPI,DDAPIScheduleProtocol {
    func requestTimeOutTimeInterval() -> Int32 {
        return TimeOutTimeInterval
    }
    
    func requestServiceID() -> Int32 {
        return Int32(SID_GROUP)
    }
    
    func responseServiceID() -> Int32 {
        return Int32(SID_GROUP)
    }
    
    func requestCommendID() -> Int32 {
        return Int32(IM_GROUP_CREATE_REQ)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_GROUP_CREATE_RES)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            if let builder = try? Im.Group.ImgroupCreateRsp.Builder.fromJSONToBuilder(data: data!){
                if let res = try? builder.build() {
                    let resultcode = res.resultCode
                    
                    if resultcode != 0 {
                        return nil
                    }else {
                        let entity:MTTGroupEntity = MTTGroupEntity.init()
                        entity.objID = MTTGroupEntity.localIDFrom(pbID: res.groupId)
                        entity.name = res.groupName
                        
                        for intUID in  res.userIdList {
                            let uidStr = MTTUserEntity.localIDFrom(pbID: intUID)
                            entity.groupUserIds.append(uidStr)
                            entity.addFixOrderGroupUserIDs(uID: uidStr)
                        }
                        
                        return entity
                    }
                    
                }else {
                    debugPrint("AllUserAPI builded failure")
                    return nil
                }
            }else {
                debugPrint("AllUserAPI fromJSONToBuilder failure")
                return nil
            }
        }
        return analysis
    }
    
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            
            let groupName = (object as? Array<Any>)?[0] as? String ?? ""
            let groupAvatar = (object as? Array<Any>)?[1] as? String ?? ""
            let groupUserList = (object as? Array<Any>)?[2] as? Array<String> ?? []
            
            var originalIDs:[UInt32] = []
            for localid in groupUserList{
                let intID:UInt32 = MTTUtil.changeID(toOriginal: localid)
                originalIDs.append(intID)
            }
            
            let builder = Im.Group.ImgroupCreateReq.Builder()
            builder.setUserId(0)
            builder.setGroupName(groupName)
            builder.setGroupAvatar(groupAvatar)
            builder.setGroupType(.groupTypeTmp)
            builder.setMemberIdList(originalIDs)
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_GROUP),
                                           cId: Int16(IM_GROUP_CREATE_REQ),
                                           seqNo: seqno)
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                debugPrint("AllUserAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }
}

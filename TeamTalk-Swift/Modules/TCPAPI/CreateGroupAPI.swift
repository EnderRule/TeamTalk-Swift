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
    
    var groupName:String = ""
    var groupAvatarUrl:String = ""
    var groupMembers:[UInt32] = []
    var groupType:Im.BaseDefine.GroupType = .groupTypeTmp
    public convenience init(groupName:String ,avatarUrl:String,members:[UInt32],type:Im.BaseDefine.GroupType){
        self.init()
        self.groupName = groupName
        self.groupAvatarUrl = avatarUrl
        self.groupMembers = members
    }
    
    
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
            if let res = try? Im.Group.ImgroupCreateRsp.parseFrom(data: data ?? Data()) {
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
                debugPrint("CreateGroupAPI analysisReturnData failure")
                return nil
            }
        }
        return analysis
    }
    
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            let builder = Im.Group.ImgroupCreateReq.Builder()
            builder.setUserId(0)
            builder.setGroupName(self.groupName)
            builder.setGroupAvatar(self.groupAvatarUrl)
            builder.setGroupType(self.groupType)
            builder.setMemberIdList(self.groupMembers)
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_GROUP),
                                           cId: Int16(IM_GROUP_CREATE_REQ),
                                           seqNo: seqno)
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                debugPrint("CreateGroupAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }
}

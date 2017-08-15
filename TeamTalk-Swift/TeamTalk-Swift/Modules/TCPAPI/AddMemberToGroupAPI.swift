//
//  AddMemberToGroupAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class AddMemberToGroupAPI: DDSuperAPI,DDAPIScheduleProtocol {

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
        return Int32(IM_GROUP_CHANGE_MEMBER_REQ)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_GROUP_CHANGE_MEMBER_RES)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            if let builder = try? Im.Group.ImgroupChangeMemberRsp.Builder.fromJSONToBuilder(data: data!){
                if let res = try? builder.build() {
                    let resultcode:UInt32 = res.resultCode
                    var array:[String] = []
                    if resultcode != 0 {
                        return array
                    }else {
                        for obj in res.curUserIdList {
                            let userID:String = MTTUserEntity.localIDFrom(pbID: obj)
                            array.append(userID)
                        }
                        return array
                    }
                }else {
                    debugPrint("AddMemberToGroupAPI builded failure")
                    return nil
                }
            }else {
                debugPrint("AddMemberToGroupAPI fromJSONToBuilder failure")
                return nil
            }
        }
        return analysis
    }
    
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            let groupID:String = (object as? Array<Any>)?[0] as? String ?? "gid_0"
            let userList:[String] = (object as? Array<Any>)?[1] as? [String] ?? []
            
            var originalUsers:[UInt32] = []
            
            for userid in  userList {
                let uid:UInt32 = MTTUtil.changeID(toOriginal: userid)
                originalUsers.append(uid)
            }
            
            let builder = Im.Group.ImgroupChangeMemberReq.Builder()
            builder.setUserId(0)
            builder.setGroupId(MTTUtil.changeID(toOriginal: groupID))
            builder.setMemberIdList(originalUsers)
            builder.setChangeType(.groupModifyTypeAdd)
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_GROUP), cId: Int16(IM_GROUP_CHANGE_MEMBER_REQ), seqNo: seqno)
            
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                debugPrint("AddMemberToGroupAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }
}

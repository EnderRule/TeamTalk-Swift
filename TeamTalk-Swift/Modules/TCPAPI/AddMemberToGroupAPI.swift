//
//  AddMemberToGroupAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class AddMemberToGroupAPI: DDSuperAPI,DDAPIScheduleProtocol {

    var groupID:UInt32 = 0
    var memberIDs:[UInt32] = []
    public convenience init(groupID:UInt32,memberIDs:[UInt32]){
        self.init()
        self.groupID = groupID
        self.memberIDs = memberIDs
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
        return Int32(IM_GROUP_CHANGE_MEMBER_REQ)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_GROUP_CHANGE_MEMBER_RES)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            if let res = try? Im.Group.ImgroupChangeMemberRsp.parseFrom(data: data ?? Data()) {
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
                HMPrint("AddMemberToGroupAPI analysisReturnData failure")
                return []
            }
            
        }
        return analysis
    }
    
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            
            let builder = Im.Group.ImgroupChangeMemberReq.Builder()
            builder.setUserId(0)
            builder.setGroupId(self.groupID)
            builder.setMemberIdList(self.memberIDs)
            builder.setChangeType(.groupModifyTypeAdd)
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_GROUP), cId: Int16(IM_GROUP_CHANGE_MEMBER_REQ), seqNo: seqno)
            
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                HMPrint("AddMemberToGroupAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }
}

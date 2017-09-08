//
//  DeleteMemberFromGroupAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class DeleteMemberFromGroupAPI: DDSuperAPI,DDAPIScheduleProtocol {
    var deleteByUserID:UInt32 = 0
    var memberIDs:[UInt32] = []
    var groupID:UInt32 = 0
    public convenience  init(groupID:UInt32,memberIDs:[UInt32],deleteByUserID:UInt32) {
        self.init()
        self.deleteByUserID = deleteByUserID
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
                let resultcode = res.resultCode
                
                if resultcode != 0 {
                    return nil
                }else {
                    let groupID = MTTGroupEntity.localIDFrom(pbID: res.groupId)
                    let entity:MTTGroupEntity = DDGroupModule.instance().getGroupByGId(groupID)
                    
                    var groupuids:[String] = []
                    for intUID in  res.curUserIdList {
                        let uidStr = MTTUserEntity.localIDFrom(pbID: intUID)
                        groupuids.append(uidStr)
                     }
                    entity.groupUserIds = groupuids
                    return entity
                }
            }else {
                debugPrint("DeleteMemberFromGroupAPI analysisReturnData failure")
                return nil
            }
        }
        return analysis
    }
    
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            let builder = Im.Group.ImgroupChangeMemberReq.Builder()
            builder.setUserId(self.deleteByUserID)
            builder.setChangeType(.groupModifyTypeDel)
            builder.setGroupId(self.groupID)
            builder.setMemberIdList(self.memberIDs)
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_GROUP),
                                           cId: Int16(IM_GROUP_CHANGE_MEMBER_REQ),
                                           seqNo: seqno)
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                debugPrint("DeleteMemberFromGroupAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }
}

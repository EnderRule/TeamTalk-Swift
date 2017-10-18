//
//  ShieldGroupMessageAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class ShieldGroupMessageAPI: DDSuperAPI,DDAPIScheduleProtocol {
    
    var groupID:UInt32 = 0
    var shieldState:UInt32 = 0
    public convenience init(groupID:UInt32,shieldState:UInt32){
        self.init()
        self.groupID = groupID
        self.shieldState = shieldState
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
        return Int32(IM_GROUP_SHIELD_REQ)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_GROUP_SHIELD_RES)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            if let res = try? Im.Group.ImgroupShieldRsp.parseFrom(data: data ?? Data()) {
                return res.resultCode
                
            }else {
                HMPrint("ShieldGroupMessageAPI analysisReturnData failure")
                return 0
            }
        }
        return analysis
    }
    
    // [groupID,(isshield as 0 or 1)]
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            let builder = Im.Group.ImgroupShieldReq.Builder()
            builder.setUserId(0)
            builder.setGroupId(self.groupID)
            builder.setShieldStatus(self.shieldState)
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_GROUP),
                                           cId: Int16(IM_GROUP_SHIELD_REQ),
                                           seqNo: seqno)
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                HMPrint("ShieldGroupMessageAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }
}

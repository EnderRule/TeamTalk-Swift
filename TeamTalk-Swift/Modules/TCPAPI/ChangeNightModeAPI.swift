//
//  ChangeNightModeAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class ChangeNightModeAPI: DDSuperAPI,DDAPIScheduleProtocol {
    
    var isShield:Bool = false
    public convenience init(isShield:Bool){
        self.init()
        self.isShield = isShield
    }
    
    func requestTimeOutTimeInterval() -> Int32 {
        return TimeOutTimeInterval
    }
    
    func requestServiceID() -> Int32 {
        return Int32(SID_LOGIN)
    }
    
    func responseServiceID() -> Int32 {
        return Int32(SID_LOGIN)
    }
    
    func requestCommendID() -> Int32 {
        return Int32(IM_PUSH_SHIELD_REQ)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_PUSH_SHIELD_RES)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            if let res = try? Im.Login.ImpushShieldRsp.parseFrom(data: data ?? Data()) {
                return [res.shieldStatus]
            }else {

                HMPrint("ChangeNightModeAPI analysisReturnData failure")
                return []
            }
        }
        return analysis
    }
    // [(isshield as 0 or 1)]
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
           
            let builder = Im.Login.ImpushShieldReq.Builder()
            builder.setUserId(0)
            builder.setShieldStatus(self.isShield ? 1 : 0)
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_LOGIN),
                                           cId: Int16(IM_PUSH_SHIELD_REQ),
                                           seqNo: seqno)
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                HMPrint("ChangeNightModeAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }
}

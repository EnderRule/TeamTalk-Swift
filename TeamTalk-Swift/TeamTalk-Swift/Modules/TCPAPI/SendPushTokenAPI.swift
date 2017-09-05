//
//  SendPushTokenAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class SendPushTokenAPI: DDSuperAPI,DDAPIScheduleProtocol {
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
        return Int32(IM_DEVICE_TOKEN_REQ)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_DEVICE_TOKEN_RES)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            return nil
        }
        return analysis
    }
    
    // object即为pushToken
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            let pushToken:String = object as? String ?? ""
            
            let builder = Im.Login.ImdeviceTokenReq.Builder()
            builder.setUserId(MTTUserEntity.pbIDFrom(localID: currentUser().userId))
            builder.setDeviceToken(pushToken)
           
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_LOGIN),
                                           cId: Int16(IM_DEVICE_TOKEN_REQ),
                                           seqNo: seqno)
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                debugPrint("SendPushTokenAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }
    
    
}

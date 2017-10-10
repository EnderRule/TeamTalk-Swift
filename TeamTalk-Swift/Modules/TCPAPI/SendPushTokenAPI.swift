//
//  SendPushTokenAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class SendPushTokenAPI: DDSuperAPI,DDAPIScheduleProtocol {
    
    var pushToken:String = ""
    public convenience init(pushToken:String){
        self.init()
        self.pushToken = pushToken
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
        return Int32(IM_DEVICE_TOKEN_REQ)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_DEVICE_TOKEN_RES)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
//            if let str = String.init(data: data ?? Data(), encoding: .utf8){
//                debugPrint("sendpushtokenapi return data:",str)
//            }
            return nil
        }
        return analysis
    }
    
    // object即为pushToken
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            
            let builder = Im.Login.ImdeviceTokenReq.Builder()
            builder.setUserId(UInt32(HMCurrentUser().intUserID))
            builder.setDeviceToken(self.pushToken)
           
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

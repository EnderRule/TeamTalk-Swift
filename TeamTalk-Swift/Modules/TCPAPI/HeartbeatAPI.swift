//
//  HeartbeatAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class HeartbeatAPI: DDSuperAPI,DDAPIScheduleProtocol {
    func requestTimeOutTimeInterval() -> Int32 {
        return 0
        
    }
    func requestServiceID() -> Int32 {
        return Int32(SID_OTHER)
    }
    
    func responseServiceID() -> Int32 {
        return Int32(SID_OTHER)
    }
    
    func requestCommendID() -> Int32 {
        return Int32(IM_HEART_BEAT)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_HEART_BEAT)
    }
    
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            return nil 
        }
        return analysis
    }
    
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            
            let heartbeatBuilder = Im.Other.ImheartBeat.Builder()
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_OTHER), cId: Int16(IM_HEART_BEAT), seqNo: seqno)
            
            if let data = try? heartbeatBuilder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                HMPrint("HeartbeatAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }
}

//
//  KickPCClientAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

//把PC端踢下线
class KickPCClientAPI: DDSuperAPI,DDAPIScheduleProtocol {
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
        return Int32(IM_KICK_PC_CLIENT_REQ)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_KICK_PC_CLIENT_RES)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            if let res = try? Im.Login.ImkickPcclientRsp.parseFrom(data: data ?? Data()) {
                return [res.resultCode]
            }else {
                HMPrint("KickPCClientAPI analysisReturnData failure")
                return []
            }
        }
        return analysis
    }
    
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            let builder = Im.Login.ImkickPcclientReq.Builder()
            builder.setUserId(0)
            
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_LOGIN),
                                           cId: Int16(IM_KICK_PC_CLIENT_REQ),
                                           seqNo: seqno)
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                HMPrint("KickPCClientAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }
}

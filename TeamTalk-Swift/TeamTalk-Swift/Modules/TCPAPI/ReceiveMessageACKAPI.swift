//
//  ReceiveMessageACKAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class ReceiveMessageACKAPI: DDSuperAPI,DDAPIScheduleProtocol {
    func requestTimeOutTimeInterval() -> Int32 {
        return 0
        
    }
    func requestServiceID() -> Int32 {
        return Int32(SID_MSG)
    }
    
    func responseServiceID() -> Int32 {
        return Int32(SID_MSG)
    }
    
    func requestCommendID() -> Int32 {
        return Int32(IM_MSG_DATA_ACK)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_MSG_DATA_ACK)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            return nil
        }
        return analysis
    }

    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            let msgid:UInt32 = (object as? Array<Any>)?[1] as? UInt32 ?? 0
            let sessionId:UInt32 = MTTUtil.changeID(toOriginal: ((object as? Array<Any>)?[2] as? String ?? "uid_0"))
            let sessionType:Im.BaseDefine.SessionType = (object as? Array<Any>)?[3] as? Im.BaseDefine.SessionType ?? Im.BaseDefine.SessionType.sessionTypeSingle
            
            let builder = Im.Message.ImmsgDataAck.Builder()
            builder.setUserId(0)
            builder.setMsgId(msgid)
            builder.setSessionId(sessionId)
            builder.setSessionType(sessionType)
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_MSG), cId: Int16(IM_MSG_DATA_ACK), seqNo: seqno)
            
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                debugPrint("ReceiveMessageACKAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }
}

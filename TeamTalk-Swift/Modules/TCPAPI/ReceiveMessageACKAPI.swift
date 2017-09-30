//
//  ReceiveMessageACKAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class ReceiveMessageACKAPI: DDSuperAPI,DDAPIScheduleProtocol {
    
    var msgID:UInt32 = 0
    var sessionID:UInt32 = 0
    var sessionType:Im.BaseDefine.SessionType = .sessionTypeSingle
    
    public convenience init(msgID:UInt32,sessionID:UInt32,sessionType:SessionType_Objc){
        self.init()
        self.msgID = msgID
        self.sessionID = sessionID
        if sessionType == .sessionTypeSingle{
            self.sessionType = .sessionTypeSingle
        }else {
            self.sessionType = .sessionTypeGroup
        }
    }
    
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
            
            let builder = Im.Message.ImmsgDataAck.Builder()
            builder.setUserId(0)
            builder.setMsgId(self.msgID)
            builder.setSessionId(self.sessionID)
            builder.setSessionType(self.sessionType)
            
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

//
//  MsgReadACKAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class MsgReadACKAPI: DDSuperAPI,DDAPIScheduleProtocol {
    
    private var sessionID:UInt32 = 0
    private var msgID:UInt32 = 0
    private var sessionType:Im.BaseDefine.SessionType = .sessionTypeSingle
    
    public convenience init(sessionID:UInt32,msgID:UInt32,sessionType:Im.BaseDefine.SessionType) {
        self.init()
        self.sessionID = sessionID
        self.msgID = msgID
        self.sessionType = sessionType
        
    }
    
    func requestTimeOutTimeInterval() -> Int32 {
        return 0
    }
    
    func requestServiceID() -> Int32 {
        return Int32(SID_MSG)
    }
    
    func responseServiceID() -> Int32 {
        return Int32(0)
    }
    
    func requestCommendID() -> Int32 {
        return Int32(IM_MSG_DATA_READ_ACK)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(0)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            return nil
        }
        return analysis
    }
    
    // object 格式 [sessoinID,msgID,sessionType] as [String]
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            
            let builder = Im.Message.ImmsgDataReadAck.Builder()
            builder.setUserId(0)
            builder.setSessionId(self.sessionID)
            builder.setMsgId(self.msgID)
            builder.setSessionType(self.sessionType)
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_MSG),
                                           cId: Int16(IM_MSG_DATA_READ_ACK),
                                           seqNo: seqno)
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                debugPrint("MsgReadACKAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }

}

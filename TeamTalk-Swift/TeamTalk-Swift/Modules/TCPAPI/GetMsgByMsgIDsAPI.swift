//
//  GetMsgByMsgIDsAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class GetMsgByMsgIDsAPI: DDSuperAPI,DDAPIScheduleProtocol {
    
    var sessionID:UInt32 = 0
    var sessionType:Im.BaseDefine.SessionType = .sessionTypeSingle
    var msgIDs:[UInt32] = []
    public convenience init(sessionID:UInt32,sessionType:SessionType_Objc,msgIDs:[UInt32]){
        self.init()
        self.sessionID = sessionID
        self.sessionType = sessionType == .sessionTypeSingle ? .sessionTypeSingle : .sessionTypeGroup
        
        self.msgIDs = msgIDs
    }
    
    
    func requestTimeOutTimeInterval() -> Int32 {
        return TimeOutTimeInterval
    }
    
    func requestServiceID() -> Int32 {
        return Int32(SID_MSG)
    }
    
    func responseServiceID() -> Int32 {
        return Int32(SID_MSG)
    }
    
    func requestCommendID() -> Int32 {
        return Int32(IM_GET_MSG_BY_ID_REQ)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_GET_MSG_BY_ID_RES)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            if let res = try? Im.Message.ImgetMsgByIdRsp.parseFrom(data: data ?? Data()) {
                return res.msgList
            }else {
                debugPrint("GetMsgByMsgIDsAPI analysisReturnData failure")
                return []
            }
        }
        return analysis
    }
    
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            let builder = Im.Message.ImgetMsgByIdReq.Builder()
            builder.setUserId(0)
            builder.setSessionId(self.sessionID)
            builder.setSessionType(self.sessionType)
            builder.setMsgIdList(self.msgIDs)
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_MSG),
                                           cId: Int16(IM_GET_MSG_BY_ID_REQ),
                                           seqNo: seqno)
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                debugPrint("GetMsgByMsgIDsAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }
}

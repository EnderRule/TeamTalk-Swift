//
//  GetMessageQueueAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class GetMessageQueueAPI: DDSuperAPI,DDAPIScheduleProtocol {
    
    var msgIDBegin:UInt32 = 0
    var count:Int = 0
    var sessionType:Im.BaseDefine.SessionType = .sessionTypeSingle
    var sessionID:UInt32 = 0
    
    public convenience init(sessionID:UInt32,sessionType:SessionType_Objc,msgIDBegin:UInt32,count:Int){
        self.init()
        self.sessionID = sessionID
        self.sessionType = (sessionType == .sessionTypeSingle) ?  .sessionTypeSingle : .sessionTypeGroup
        self.count = count
        self.msgIDBegin = msgIDBegin
    }
    
    func requestTimeOutTimeInterval() -> Int32 {
        return 20
    }
    
    func requestServiceID() -> Int32 {
        return Int32(SID_MSG)
    }
    
    func responseServiceID() -> Int32 {
        return Int32(SID_MSG)
    }
    
    func requestCommendID() -> Int32 {
        return Int32(IM_GET_MSG_LIST_REQ)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_GET_MSG_LIST_RSP)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            if let res = try? Im.Message.ImgetMsgListRsp.parseFrom(data: data ?? Data()) {
               let sessionType = res.sessionType
                let sessionID = MTTSessionEntity.sessionIDFrom(pbID: res.sessionId, BaseSessionType: sessionType)
                
                var msgArray:[MTTMessageEntity] = []
                for msginfo in res.msgList{
                    let msgentity = MTTMessageEntity.initWith(msgInfo: msginfo, sessionType: sessionType)
                    msgentity.sessionId = sessionID
//                    msgentity.state = .SendSuccess
                    
                    msgentity.dbSave(completion: nil)
                    msgArray.append(msgentity)
                }
                return msgArray
            }else {
                debugPrint("GetMessageQueueAPI analysisReturnData failure")
                return []
            }
        }
        return analysis
    }
    
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            let builder = Im.Message.ImgetMsgListReq.Builder()
            builder.setUserId(0)
            builder.setMsgIdBegin(self.msgIDBegin)
            builder.setMsgCnt(UInt32(self.count))
            builder.setSessionType(self.sessionType)
            builder.setSessionId(self.sessionID)

            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_MSG),
                                           cId: Int16(IM_GET_MSG_LIST_REQ),
                                           seqNo: seqno)
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                debugPrint("GetMessageQueueAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }
}

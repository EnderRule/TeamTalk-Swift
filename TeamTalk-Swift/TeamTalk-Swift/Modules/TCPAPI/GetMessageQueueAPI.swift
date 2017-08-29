//
//  GetMessageQueueAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class GetMessageQueueAPI: DDSuperAPI,DDAPIScheduleProtocol {
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
                    let msgentity = MTTMessageEntity.init(msgInfo: msginfo, sessionType: sessionType)
                    msgentity.sessionId = sessionID
                    msgentity.state = .SendSuccess
                    
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
    
    //打包數據,object 格式：[msgIDbegin,msgcount, sessiontype,sessiongid] as [String]
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            
            let msgIDbegin:Int32 = ( "\((object as! [Any])[0])" as NSString).intValue
            let count:Int32 = ( "\((object as! [Any])[1])" as NSString).intValue
            let typeint:Int32 = ( "\((object as! [Any])[2])" as NSString).intValue
            let sessionID:UInt32 = MTTBaseEntity.pbIDFrom(localID: "\((object as! [Any])[3])" )
            
            var sessionType:Im.BaseDefine.SessionType = .sessionTypeSingle
            if typeint == 2 {
                sessionType = Im.BaseDefine.SessionType.sessionTypeGroup
            }
            
            let builder = Im.Message.ImgetMsgListReq.Builder()
            builder.setUserId(0)
            builder.setMsgIdBegin(UInt32(msgIDbegin))
            builder.setMsgCnt(UInt32(count))
            builder.setSessionType(sessionType)
            builder.setSessionId(sessionID)

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

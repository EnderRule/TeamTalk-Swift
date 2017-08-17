//
//  GetUnreadMessagesAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class GetUnreadMessagesAPI: DDSuperAPI,DDAPIScheduleProtocol {
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
        return Int32(IM_UNREAD_MSG_CNT_REQ)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_UNREAD_MSG_CNT_RSP)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            if let res = try? Im.Message.ImunreadMsgCntRsp.parseFrom(data: data ?? Data()) {
                
                var sessionArray:[MTTSessionEntity] = []
                for unreadInfo in res.unreadinfoList{
                    let sessionEntity = MTTSessionEntity.init(unreadInfo: unreadInfo)//.init()
                    sessionArray.append(sessionEntity)
                }
                var dic:[String:Any] = [:]
                dic.updateValue(sessionArray, forKey: "sessions")
                dic.updateValue(res.totalCnt, forKey: "m_total_cnt")
                
                return dic
            }else {
                debugPrint("GetMessageQueueAPI analysisReturnData failure")
                return [:]
            }
        }
        return analysis
    }
    
    //打包數據,object 格式：[msgIDbegin,msgcount, sessiontype,sessiongid] as [String]
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            
            let builder = Im.Message.ImunreadMsgCntReq.Builder()
            builder.setUserId(0)
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_MSG),
                                           cId: Int16(IM_UNREAD_MSG_CNT_REQ),
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

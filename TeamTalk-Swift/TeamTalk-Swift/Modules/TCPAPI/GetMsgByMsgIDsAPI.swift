//
//  GetMsgByMsgIDsAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class GetMsgByMsgIDsAPI: DDSuperAPI,DDAPIScheduleProtocol {
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
    
    //打包數據,object 格式：[sessiontype,sessiongid,[msgIDs]] as [Any]
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            
            let typeint:Int32 = ( "\((object as! [Any])[0])" as NSString).intValue
            let type = Im.BaseDefine.SessionType(rawValue: typeint) ?? .sessionTypeSingle
            let sessionID:UInt32 = MTTBaseEntity.pbIDFrom(localID: "\((object as! [Any])[1])" )
            
            let msgIDs:[UInt32] = ((object as! [Any])[2]) as! [UInt32]
            
            let builder = Im.Message.ImgetMsgByIdReq.Builder()
            builder.setUserId(0)
            builder.setSessionId(sessionID)
            builder.setSessionType(type)
            builder.setMsgIdList(msgIDs)
            
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

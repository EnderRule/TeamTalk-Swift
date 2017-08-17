//
//  GetLatestMsgIdAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class GetLatestMsgIdAPI: DDSuperAPI,DDAPIScheduleProtocol {
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
        return Int32(IM_GET_LASTEST_MSGID_REQ)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_GET_LASTEST_MSGID_RES)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            if let res = try? Im.Message.ImgetLatestMsgIdRsp.parseFrom(data: data ?? Data()) {
                return res.latestMsgId
            }else {
                debugPrint("GetLatestMsgIdAPI analysisReturnData failure")
                return 0
            }
        }
        return analysis
    }
    
    //打包數據,object 格式：[sessiontype,sessiongid] as [String]
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
        
            let typeint:Int32 = ( "\((object as! [Any])[0])" as NSString).intValue
            let type = Im.BaseDefine.SessionType(rawValue: typeint) ?? .sessionTypeSingle
            let sessionID:UInt32 = MTTBaseEntity.pbIDFrom(localID: "\((object as! [Any])[1])" )

            let builder = Im.Message.ImgetLatestMsgIdReq.Builder()
            builder.setUserId(0)
            builder.setSessionId(sessionID)
            builder.setSessionType(type)
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_MSG),
                                           cId: Int16(IM_GET_LASTEST_MSGID_REQ),
                                           seqNo: seqno)
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                debugPrint("GetLatestMsgIdAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }

}

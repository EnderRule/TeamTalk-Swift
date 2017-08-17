//
//  GetRecentSessionAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class GetRecentSessionAPI: DDSuperAPI,DDAPIScheduleProtocol {
    func requestTimeOutTimeInterval() -> Int32 {
        return TimeOutTimeInterval
    }
    
    func requestServiceID() -> Int32 {
        return Int32(SID_BUDDY_LIST)
    }
    
    func responseServiceID() -> Int32 {
        return Int32(SID_BUDDY_LIST)
    }
    
    func requestCommendID() -> Int32 {
        return Int32(IM_RECENT_CCONTACT_SESSION_REQ)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_RECENT_CCONTACT_SESSION_RES)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            if let res = try? Im.Buddy.ImrecentContactSessionRsp.parseFrom(data: data ?? Data()) {
                var array:[MTTSessionEntity] = []
                for sessionInfo in res.contactSessionList {
                    let sessionType:SessionType_Objc = SessionType_Objc(rawValue:  sessionInfo.sessionType.rawValue) ?? .sessionTypeSingle
                    
                    var sessionID:String = ""
                    if sessionType == .sessionTypeSingle {
                        sessionID = MTTUserEntity.localIDFrom(pbID: sessionInfo.sessionId)
                    }else{
                        sessionID = MTTGroupEntity.localIDFrom(pbID: sessionInfo.sessionId)
                    }
                    
                    let sessionEntity = MTTSessionEntity.init(sessionID: sessionID, sessionName: nil , type: sessionType)
                    
                    if let encryMsg = String.init(data: sessionInfo.latestMsgData, encoding: .utf8){
                        sessionEntity.lastMsg = encryMsg.decrypt()
                    }
                    
                    sessionEntity.lastMsgID = Int( sessionInfo.latestMsgId)
                    sessionEntity.timeInterval = TimeInterval(sessionInfo.updatedTime)
                    
                    array.append(sessionEntity)
                }
                return array
            }else {
                debugPrint("GetRecentSessionAPI analysisReturnData failure")
                return []
            }
        }
        return analysis
    }
    
    //打包數據,object 格式：[latestupdatetime] as [String]
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            
            let latestupdatetime:Int32 = ( "\((object as! [Any])[0])" as NSString).intValue
            
            let builder = Im.Buddy.ImrecentContactSessionReq.Builder()
            builder.setUserId(0)
            builder.setLatestUpdateTime(UInt32(latestupdatetime))
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_BUDDY_LIST),
                                           cId: Int16(IM_RECENT_CCONTACT_SESSION_REQ),
                                           seqNo: seqno)
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                debugPrint("GetRecentSessionAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }

}

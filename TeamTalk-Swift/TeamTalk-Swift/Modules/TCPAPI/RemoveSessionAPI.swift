//
//  RemoveSessionAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class RemoveSessionAPI: DDSuperAPI,DDAPIScheduleProtocol {
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
        return Int32(SID_BUDDY_LIST)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_REMOVE_SESSION_RES)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            return nil
        }
        return analysis
    }
    
    //打包數據,object 格式：[latestupdatetime] as [String]
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            let sessionID:UInt32 = MTTBaseEntity.pbIDFrom(localID: "\((object as! [Any])[0])" )
            let typeID:UInt32 =  UInt32(("\((object as! [Any])[1])" as NSString).intValue)
            
            var sesssionType = Im.BaseDefine.SessionType.sessionTypeSingle
            if typeID == 2 {
                sesssionType = Im.BaseDefine.SessionType.sessionTypeGroup
            }
            
            
            let builder = Im.Buddy.ImremoveSessionReq.Builder()
            builder.setUserId(0)
            builder.setSessionId(sessionID)
            builder.setSessionType(sesssionType)
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_BUDDY_LIST),
                                           cId: Int16(IM_REMOVE_SESSION_RES),
                                           seqNo: seqno)
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                debugPrint("RemoveSessionAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }

}

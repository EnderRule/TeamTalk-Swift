//
//  MsgReadACKAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class MsgReadACKAPI: DDSuperAPI {
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
            let sessionID:UInt32 = MTTBaseEntity.pbIDFrom(localID: "\((object as! [Any])[0])" )
            let msgID:UInt32 =  UInt32(("\((object as! [Any])[1])" as NSString).intValue)
            let typeID:UInt32 =  UInt32(("\((object as! [Any])[2])" as NSString).intValue)
            
            var sesssionType = Im.BaseDefine.SessionType.sessionTypeSingle
            if typeID == 2 {
                sesssionType = Im.BaseDefine.SessionType.sessionTypeGroup
            }
            
            let builder = Im.Message.ImmsgDataReadAck.Builder()
            builder.setUserId(0)
            builder.setSessionId(sessionID)
            builder.setMsgId(msgID)
            builder.setSessionType(sesssionType)
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_MSG),
                                           cId: Int16(IM_MSG_DATA_READ_ACK),
                                           seqNo: seqno)
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                debugPrint("LogoutAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }

}

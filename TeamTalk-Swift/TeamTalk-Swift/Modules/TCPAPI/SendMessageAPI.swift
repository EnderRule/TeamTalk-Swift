//
//  SendMessageAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

// object 数组 [fromID,toID,data,messageType,messageID]

class SendMessageAPI: DDSuperAPI {
    func requestTimeOutTimeInterval() -> Int32 {
        return 10
    }
    
    func requestServiceID() -> Int32 {
        return Int32(SID_MSG)
    }
    
    func responseServiceID() -> Int32 {
        return Int32(SID_MSG)
    }
    
    func requestCommendID() -> Int32 {
        return Int32(IM_MSG_DATA)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_MSG_DATA_ACK)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            if let res = try? Im.Message.ImmsgDataAck.parseFrom(data: data ?? Data()) {
                return [res.msgId,res.sessionId]
            }else {
                debugPrint("SendMessageAPI analysisReturnData failure")
                return []
            }
        }
        return analysis
    }
    

    
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            
            let toID:UInt32 = MTTBaseEntity.pbIDFrom(localID:  "\((object as! [Any])[1])")
            let data:Data = (object as! [Any])[2] as? Data ?? Data()
            let msgtypeInt:Int32   = ( "\((object as! [Any])[3])" as NSString).intValue
            let msgtype:Im.BaseDefine.MsgType = Im.BaseDefine.MsgType(rawValue:msgtypeInt) ?? .msgTypeSingleText
           
            let builder = Im.Message.ImmsgData.Builder()
            builder.setFromUserId(0)
            builder.setToSessionId(toID)
            builder.setMsgData(data)
            builder.setMsgType(msgtype)
            builder.setMsgId(0)
            builder.setCreateTime(0)
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_MSG),
                                           cId: Int16(IM_MSG_DATA),
                                           seqNo: seqno)
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                debugPrint("SendMessageAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }
}

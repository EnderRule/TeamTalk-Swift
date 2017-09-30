//
//  ShakeAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class ShakeAPI: DDSuperAPI,DDAPIScheduleProtocol {
    
    var shakeToUserID:UInt32 = 0
    public convenience init(toUserID:UInt32){
        self.init()
        self.shakeToUserID = toUserID
    }
    
    func requestTimeOutTimeInterval() -> Int32 {
        return TimeOutTimeInterval
    }
    
    func requestServiceID() -> Int32 {
        return Int32(SID_SWITCH_SERVICE)
    }
    
    func responseServiceID() -> Int32 {
        return Int32(SID_SWITCH_SERVICE)
    }
    
    func requestCommendID() -> Int32 {
        return Int32(IM_P2P_CMD_MSG)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_P2P_CMD_MSG)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
             return nil
        }
        return analysis
    }
    
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            let theContent = NSString.init(format: "{\"cmd_id\":%i,\"content\":\"%@\",\"service_id\":%i}",1<<16|1,"shakewindow",1)
 
            let builder = Im.SwitchService.Imp2PcmdMsg.Builder()
            builder.setToUserId(self.shakeToUserID)
            builder.setFromUserId(0)
            builder.setCmdMsgData(theContent as String)
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_SWITCH_SERVICE),
                                           cId: Int16(IM_P2P_CMD_MSG),
                                           seqNo: seqno)
            
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                debugPrint("ShakeAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }
}

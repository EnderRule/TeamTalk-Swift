//
//  UserStatAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

//用户在线状态
class UserStatAPI: DDSuperAPI,DDAPIScheduleProtocol {
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
        return Int32(IM_USERS_STAT_REQ)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_USERS_STAT_RSP)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            if let res = try? Im.Buddy.ImusersStatRsp.parseFrom(data: data ?? Data()) {
                
                var userstatList:[Any] = []
                for statinfo in res.userStatList {
                    userstatList.append([statinfo.userId,statinfo.status.rawValue])
//                    userstatList.append(statinfo.userId)
//                    userstatList.append(statinfo.status.rawValue)
                }
                return userstatList
            }else {
                debugPrint("UserStatAPI analysisReturnData failure")
                return []
            }
        }
        return analysis
    }
    
    // [userids] as [UInt32]
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            let userIDs = object as! [UInt32]
            
            let builder = Im.Buddy.ImusersStatReq.Builder()
            builder.setUserId(0)
            builder.setUserIdList(userIDs )
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_BUDDY_LIST),
                                           cId: Int16(IM_USERS_STAT_REQ),
                                           seqNo: seqno)
            
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                debugPrint("UserStatAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }
}

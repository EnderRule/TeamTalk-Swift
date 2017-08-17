//
//  AllUserAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class AllUserAPI: DDSuperAPI,DDAPIScheduleProtocol {
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
        return Int32(IM_ALL_USER_REQ)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_ALL_USER_RES)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            if let res = try? Im.Buddy.ImallUserRsp.parseFrom(data: data ?? Data()) {
                var userAndVersion:[String:Any] = [:]
                userAndVersion.updateValue(res.latestUpdateTime, forKey: "alllastupdatetime")
                
                var userList:[MTTUserEntity] = []
                for userinfo in res.userList {
                    let userEntity = MTTUserEntity.init(userinfo: userinfo)
                    userList.append(userEntity)
                }
                userAndVersion.updateValue(userList, forKey: "userlist")
                
                return userAndVersion
            }else {
                debugPrint("AllUserAPI analysisReturnData failure")
                return [:]
            }
        }
        return analysis
    }
    
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            let lastupdatetime:Int = NSString.init(format: "%@", (object as? Array<Any>)?[0] as? CVarArg ?? "0").integerValue
            
            let builder = Im.Buddy.ImallUserReq.Builder()
            builder.setUserId(0)
            builder.setLatestUpdateTime(UInt32(lastupdatetime))
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_BUDDY_LIST),
                                           cId: Int16(IM_ALL_USER_REQ),
                                           seqNo: seqno)
            
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                debugPrint("AllUserAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }
}

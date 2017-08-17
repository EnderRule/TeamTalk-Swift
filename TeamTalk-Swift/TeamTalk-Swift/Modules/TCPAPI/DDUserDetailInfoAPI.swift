//
//  DDUserDetailInfoAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class DDUserDetailInfoAPI: DDSuperAPI,DDAPIScheduleProtocol {
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
        return Int32(IM_USERS_INFO_REQ)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_USERS_INFO_RES)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            if let res = try? Im.Buddy.ImusersInfoRsp.parseFrom(data: data ?? Data()) {
                var userList :[MTTUserEntity] = []
                
                for userinfo in res.userInfoList {
                    let user  = MTTUserEntity.init(userinfo: userinfo)
                    userList.append(user)
                }
                return userList
                
            }else {
                debugPrint("DDUserDetailInfoAPI analysisReturnData failure")
                return []
            }
        }
        return analysis
    }
    
    //打包數據,object 格式：[Int] 或 [UInt32]
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            let users = object as? [UInt32] ?? []
            let builder = Im.Buddy.ImusersInfoReq.Builder()
            builder.setUserId(0)
            builder.setUserIdList(users)
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_BUDDY_LIST),
                                           cId: Int16(IM_USERS_INFO_REQ),
                                           seqNo: seqno)
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                debugPrint("DDUserDetailInfoAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }
}

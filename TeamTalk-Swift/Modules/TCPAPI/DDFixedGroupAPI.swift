//
//  DDFixedGroupAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class DDFixedGroupAPI: DDSuperAPI,DDAPIScheduleProtocol {
    func requestTimeOutTimeInterval() -> Int32 {
        return TimeOutTimeInterval
    }
    
    func requestServiceID() -> Int32 {
        return Int32(SID_GROUP)
    }
    
    func responseServiceID() -> Int32 {
        return Int32(SID_GROUP)
    }
    
    func requestCommendID() -> Int32 {
        return Int32(IM_NORMAL_GROUP_LIST_REQ)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_NORMAL_GROUP_LIST_RES)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            if let res = try? Im.Group.ImnormalGroupListRsp.parseFrom(data: data ?? Data()) {
                var array:[[String:Any]] = []
                
                for obj in res.groupVersionList {
                    let groupInfo:[String:Any] = ["groupid":obj.groupId,"version":obj.version]
                    array.append(groupInfo)
                }
                
                return array
                
            }else {
                debugPrint("DDFixedGroupAPI analysisReturnData failure")
                return []
            }
        }
        return analysis
    }
    
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            
            let builder = Im.Group.ImnormalGroupListReq.Builder()
            builder.setUserId(0)
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_GROUP),
                                           cId: Int16(IM_NORMAL_GROUP_LIST_REQ),
                                           seqNo: seqno)
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                debugPrint("DDFixedGroupAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }
}

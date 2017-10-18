//
//  GetGroupInfoAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class GetGroupInfoAPI: DDSuperAPI,DDAPIScheduleProtocol {
    
    var groupID:UInt32 = 0
    var groupVersion:UInt32 = 0
    public convenience init(groupID:UInt32,groupVersion:UInt32){
        self.init()
        self.groupID = groupID
        self.groupVersion = groupVersion
    }
    
    func requestTimeOutTimeInterval() -> Int32 {
        return 0
    }
    
    func requestServiceID() -> Int32 {
        return Int32(SID_GROUP)
    }
    
    func responseServiceID() -> Int32 {
        return Int32(SID_GROUP)
    }
    
    func requestCommendID() -> Int32 {
        return Int32(IM_GROUP_INFO_LIST_REQ)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_GROUP_INFO_LIST_RES)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            if let res = try? Im.Group.ImgroupInfoListRsp.parseFrom(data: data ?? Data()) {
                var array:[MTTGroupEntity] = []
                for groupinfo in res.groupInfoList {
                    let groupEntity = MTTGroupEntity.init(groupInfo: groupinfo)
                    array.append(groupEntity)
                }
                return array
            }else {
                HMPrint("GetGroupInfoAPI analysisReturnData failure")
                return []
            }
        }
        return analysis
    }
    //[groupid_intvalue , groupversion_intvalue]
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            let versionBuilder = Im.BaseDefine.GroupVersionInfo.Builder()
            versionBuilder.setGroupId(self.groupID)
            versionBuilder.setVersion(self.groupVersion)
            
            let listBuilder = Im.Group.ImgroupInfoListReq.Builder()
            listBuilder.setUserId(0)
            if let versioninfo = try? versionBuilder.build(){
                listBuilder.setGroupVersionList([versioninfo])
            }
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_GROUP),
                                           cId: Int16(IM_GROUP_INFO_LIST_REQ),
                                           seqNo: seqno)
            if let data = try? listBuilder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                HMPrint("GetGroupInfoAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }
}

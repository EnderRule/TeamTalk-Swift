//
//  EditSignatureAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class EditSignatureAPI: DDSuperAPI,DDAPIScheduleProtocol {
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
        return Int32(IM_CHANGE_SIGN_INFO_REQ)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_CHANGE_SIGN_INFO_RES)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            if let res = try? Im.Buddy.ImchangeSignInfoRsp.parseFrom(data: data ?? Data()) {
                return res.resultCode
                
            }else {
                debugPrint("EditSignatureAPI analysisReturnData failure")
                return 0
            }
        }
        return analysis
    }
    
    //打包數據,object 格式：[signature] as [String]
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            let signature = "\((object as! [Any])[0])"
            
            let builder = Im.Buddy.ImchangeSignInfoReq.Builder()
            builder.setUserId(MTTUserEntity.pbIDFrom(localID: RuntimeStatus.instance().user.objID))
            builder.setSignInfo(signature)
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_BUDDY_LIST),
                                           cId: Int16(IM_CHANGE_SIGN_INFO_REQ),
                                           seqNo: seqno)
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                debugPrint("EditSignatureAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }
}

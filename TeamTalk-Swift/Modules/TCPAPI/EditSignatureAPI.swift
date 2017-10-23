//
//  EditSignatureAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class EditUserInfoAPI: DDSuperAPI,DDAPIScheduleProtocol {
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
                HMPrint("EditUserInfoAPI analysisReturnData failure")
                return 0
            }
        }
        return analysis
    }
    
    private var edit_signature:String?
//    private var edit_avatar:Data?
    
    func setInfoEdit(signature:String?,avatarData:Data?){
        self.edit_signature = signature
//        self.edit_avatar = avatarData
    }
    
    
    //打包數據,object 格式： ["signature":签名,"avatar":头像图片Data]   [signature] as [String]
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
//            let signature:String  = ((object as! [String:Any])["signature"]) as? String ?? ""
//            let avatarData:Data = ((object as! [String:Any])["avatar"]) as? Data ?? Data()
            
            let builder = Im.Buddy.ImchangeSignInfoReq.Builder()

            builder.setUserId(MTTUserEntity.pbIDFrom(localID: HMLoginManager.shared.currentUser.userId))
            
            if self.edit_signature != nil {
                builder.setSignInfo(self.edit_signature!)
            }
//            if  self.edit_avatar != nil {
//                builder.setAttachData(self.edit_avatar!)
//            }
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_BUDDY_LIST),
                                           cId: Int16(IM_CHANGE_SIGN_INFO_REQ),
                                           seqNo: seqno)
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                HMPrint("EditUserInfoAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }
}

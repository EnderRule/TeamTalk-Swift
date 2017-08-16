//
//  LoginAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class LoginAPI: DDSuperAPI,DDAPIScheduleProtocol {
    func requestTimeOutTimeInterval() -> Int32 {
        return 5
        
    }
    func requestServiceID() -> Int32 {
        return Int32(SID_LOGIN)
    }
    
    func responseServiceID() -> Int32 {
        return Int32(SID_LOGIN)
    }
    
    func requestCommendID() -> Int32 {
        return Int32(IM_LOGIN_REQ)
    }
    
    func responseCommendID() -> Int32 {
        return Int32(IM_LOGIN_RES)
    }
    
    func analysisReturnData() -> Analysis! {
        let analysis:Analysis = { (data) in
            
            if let loginresBuilder = try? Im.Login.ImloginRes.Builder.fromJSONToBuilder(data: data!){
                if let loginres = try? loginresBuilder.build() {
                    let loginResult:Int32 = loginres.resultCode.rawValue
                    
                    var result:[String:Any] = [:]
                    if loginResult != 0 {
                        return result
                    }else {
                        let serverTime:UInt32 = loginres.serverTime
                        let resultString:String = loginres.resultString
                        let user = MTTUserEntity.init(userinfo: loginres.userInfo)
                        
                        result.updateValue(serverTime, forKey: "serverTime")
                        result.updateValue(resultString, forKey: "result")
                        result.updateValue(user, forKey: "user")
                        return result
                    }
                }else {
                    debugPrint("LoginApi builded failure")
                    return nil
                }
            }else {
                debugPrint("LoginApi fromJSONToBuilder failure")
                return nil
            }
        }
        return analysis
    }
    
    func packageRequestObject() -> Package! {
        let package:Package = {(object,seqno) in
            
            let clientVersion:String = "iOS/\(APP_VERSION)-\(APP_BUILD_VERSION)"
            let name:String = (object as? Array<Any>)?[0] as? String ?? ""
            let strMsg:String = (object as? Array<Any>)?[1] as? String ?? ""
            
            let builder = Im.Login.ImloginReq.Builder()
            builder.setUserName(name)
            builder.setPassword(strMsg.md5)
            builder.setClientType(.clientTypeIos)
            builder.setClientVersion(clientVersion)
            builder.setOnlineStatus(.userStatusOnline)
            
            let dataOut = DDDataOutputStream.init()
            dataOut.write(0)
            dataOut.writeTcpProtocolHeader(Int16(SID_LOGIN), cId: Int16(IM_LOGIN_REQ), seqNo: seqno)
            
            if let data = try? builder.build().data() {
                dataOut.directWriteBytes(data)
            }else {
                debugPrint("LoginAPI package builded data failure")
            }
            dataOut.writeDataCount()
            return dataOut.toByteArray()
        }
        return package
    }
}

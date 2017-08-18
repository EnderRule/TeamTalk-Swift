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
            
            if let loginres = try? Im.Login.ImloginRes.parseFrom(data: data ?? Data()) {
                let loginResult:Int32 = loginres.resultCode.rawValue
                
                var result:[String:Any] = [:]
                if loginResult != 0 {
                    debugPrint(self.classForCoder," login resultCode != 0")
                    
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
                debugPrint("LoginAPI analysisReturnData failure")
                return [:]
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
                
                debugPrint("LoginAPI package data: \((data as NSData).length) \(data)")
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

//typealias RequestCompletion = ((_ response:Any,_ error:Error)->Void)
//
//var theSeqNo:UInt16 = 0
//
///**
// *  这是一个超级类，不能被直接使用
// *  子类需实现 DDAPIScheduleProtocol 协议
// */
//
//class DDSuperAPI: NSObject {
//    
//    
//    var completion:RequestCompletion?
//    var seqNo:UInt16 = 0
//    
//    
//    public func requestWith(object:Any,completion:@escaping RequestCompletion){
//        theSeqNo += 1
//        self.seqNo = theSeqNo
//        
//        let registerApi:Bool = DDAPISchedule.instance().registerApi(self as? DDAPIScheduleProtocol)
//        if !registerApi {
//            return
//        }
//        
//        if ((self as? DDAPIScheduleProtocol)?.requestTimeOutTimeInterval() ?? 0) > 0 {
//            DDAPISchedule.instance().registerApi(self as? DDAPIScheduleProtocol)
//        }
//        
//        self.completion = completion
//        
//        if  let package = (self as? DDAPIScheduleProtocol)?.packageRequestObject() {
//            if   let requestData = package(object,self.seqNo) {
//                DDAPISchedule.instance().send(requestData)
//                DDTcpClientManager.instance().write(toSocket: requestData)
//            }
//        }
//    }
//}

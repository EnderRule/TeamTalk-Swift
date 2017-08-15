//
//  DDSuperAPI.swift
//  TeamTalk
//
//  Created by HuangZhongQing on 2017/8/14.
//  Copyright © 2017年 MoguIM. All rights reserved.
//

import UIKit

typealias RequestCompletion = ((_ response:Any,_ error:Error)->Void)

var theSeqNo:UInt16 = 0

/**
 *  这是一个超级类，不能被直接使用
 *  子类需实现 DDAPIScheduleProtocol 协议
 */

class DDSuperAPI: NSObject {
    
    
    var completion:RequestCompletion?
    var seqNo:UInt16 = 0
    
    
    public func requestWith(object:Any,completion:@escaping RequestCompletion){
        theSeqNo += 1
        self.seqNo = theSeqNo
        
         let registerApi:Bool = DDAPISchedule.instance().registerApi(self as? DDAPIScheduleProtocol)
        if !registerApi {
            return
        }
        
        if ((self as? DDAPIScheduleProtocol)?.requestTimeOutTimeInterval() ?? 0) > 0 {
            DDAPISchedule.instance().registerApi(self as? DDAPIScheduleProtocol)
        }
        
        self.completion = completion
        
        if  let package = (self as? DDAPIScheduleProtocol)?.packageRequestObject() {
            if   let requestData = package(object,self.seqNo) {
                DDAPISchedule.instance().send(requestData)
                DDTcpClientManager.instance().write(toSocket: requestData)
            }
        }
    }
}

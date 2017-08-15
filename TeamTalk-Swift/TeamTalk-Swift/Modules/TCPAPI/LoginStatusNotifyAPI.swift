//
//  LoginStatusNotifyAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class LoginStatusNotifyAPI: DDUnrequestSuperAPI ,DDAPIUnrequestScheduleProtocol {
    
    func responseCommandID() -> Int32 {
        return Int32(IM_PC_LOGIN_STATUS_NOTIFY)
    }
    
    func responseServiceID() -> Int32 {
        return Int32(SID_BUDDY_LIST)
    }
    
    func unrequestAnalysis() -> UnrequestAPIAnalysis! {
        let analysis:UnrequestAPIAnalysis = {(data) in
            if  let builder:Im.Buddy.ImpcloginStatusNotify.Builder = try? Im.Buddy.ImpcloginStatusNotify.Builder.fromJSONToBuilder(data: data!){
                if let res:Im.Buddy.ImpcloginStatusNotify = try? builder.build() {
                    var dic:[String:Any] = [:]
                    dic.updateValue(res.userId, forKey: "uid")
                    dic.updateValue(res.loginStat.rawValue, forKey: "loginStat")
                    return dic
                }else {
                    debugPrint("LoginStatusNotifyAPI builded failure")
                    return  nil
                }
            }else {
                debugPrint("LoginStatusNotifyAPI fromJSONToBuilder failure")
                return  nil
            }
        }
        return analysis
    }
}

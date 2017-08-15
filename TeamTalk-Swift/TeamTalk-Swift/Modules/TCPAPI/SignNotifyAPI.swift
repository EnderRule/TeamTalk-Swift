//
//  SignNotifyAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class SignNotifyAPI: DDUnrequestSuperAPI,DDAPIUnrequestScheduleProtocol {
    func responseCommandID() -> Int32 {
        return Int32(IM_SIGN_INFO_CHANGED_NOTIFY)
    }
    
    func responseServiceID() -> Int32 {
        return Int32(SID_BUDDY_LIST)
    }
    
    func unrequestAnalysis() -> UnrequestAPIAnalysis! {
        let analysis:UnrequestAPIAnalysis = {(data) in
            if  let builder:Im.Buddy.ImsignInfoChangedNotify.Builder = try? Im.Buddy.ImsignInfoChangedNotify.Builder.fromJSONToBuilder(data: data!){
                if let res:Im.Buddy.ImsignInfoChangedNotify = try? builder.build() {
                    var dic:[String:Any] = [:]
                    dic.updateValue(res.changedUserId, forKey: "uid")
                    dic.updateValue(res.signInfo, forKey: "sign")
                    return dic
                }else {
                    debugPrint("SignNotifyAPI builded failure")
                    return  nil
                }
            }else {
                debugPrint("SignNotifyAPI fromJSONToBuilder failure")
                return  nil
            }
        }
        return analysis
    }
}

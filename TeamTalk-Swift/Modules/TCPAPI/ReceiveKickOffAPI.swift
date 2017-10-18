//
//  ReceiveKickOffAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class ReceiveKickOffAPI: DDUnrequestSuperAPI,DDAPIUnrequestScheduleProtocol {
    func responseCommandID() -> Int32 {
        return Int32(IM_KICK_USER)
    }
    
    func responseServiceID() -> Int32 {
        return Int32(SID_LOGIN)
    }
    
    func unrequestAnalysis() -> UnrequestAPIAnalysis! {
        let analysis:UnrequestAPIAnalysis = {(data) in

            if let res:Im.Login.ImkickUser = try? Im.Login.ImkickUser.parseFrom(data: data ?? Data()) {
                return res.kickReason
            }else {
                HMPrint("ReceiveKickOffAPI analysisReturnData failure")
                return  0
            }
        }
        return analysis
    }
}

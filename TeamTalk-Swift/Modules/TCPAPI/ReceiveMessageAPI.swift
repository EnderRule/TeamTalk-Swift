//
//  ReceiveMessageAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class ReceiveMessageAPI: DDUnrequestSuperAPI,DDAPIUnrequestScheduleProtocol {
    
    func responseServiceID() -> Int32 {
        return Int32(SID_MSG)
    }
    
    func responseCommandID() -> Int32 {
        return Int32(IM_MSG_DATA)
    }
    
    func unrequestAnalysis() -> UnrequestAPIAnalysis! {
        let analysis:UnrequestAPIAnalysis = {(data) in
            if let res:Im.Message.ImmsgData = try? Im.Message.ImmsgData.parseFrom(data: data ?? Data()) {
                let entity = MTTMessageEntity.initWith(msgData: res)
//                entity.state = .SendSuccess
                return entity
            }else {
                debugPrint("ReceiveMessageAPI analysisReturnData failure")
                return  nil
            }
        }
        return analysis
    }
}

//
//  MsgReadNotifyAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class MsgReadNotifyAPI: DDUnrequestSuperAPI,DDAPIUnrequestScheduleProtocol {
    func responseServiceID() -> Int32 {
        return Int32(SID_MSG)
    }
    
    func responseCommandID() -> Int32 {
        return Int32(IM_MSG_DATA_READ_NOTIFY)
    }
    
    func unrequestAnalysis() -> UnrequestAPIAnalysis! {
        let analysis:UnrequestAPIAnalysis = {(data) in
            if  let builder:Im.Message.ImmsgDataReadNotify.Builder = try? Im.Message.ImmsgDataReadNotify.Builder.fromJSONToBuilder(data: data!){
                if let res:Im.Message.ImmsgDataReadNotify = try? builder.build() {
                    var dic:[String :Any] = [:]
                    dic .updateValue(res.sessionType.rawValue, forKey: "type")
                    dic.updateValue(res.msgId, forKey: "msgId")
                    dic.updateValue(res.sessionId, forKey: "from_id")
                    return dic
                }else {
                    debugPrint("SignNotifyAPI analysisReturnData failure")
                    return  [:]
                }
            }else {
                debugPrint("SignNotifyAPI fromJSONToBuilder failure")
                return  [:]
            }
        }
        return analysis
    }
}

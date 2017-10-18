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

            if  let res:Im.Message.ImmsgDataReadNotify = try? Im.Message.ImmsgDataReadNotify.parseFrom(data: data ?? Data()){
                var dic:[String :Any] = [:]
            
                dic .updateValue(res.sessionType.rawValue, forKey: "type")
                dic.updateValue(res.msgId, forKey: "msgId")
                dic.updateValue(res.sessionId, forKey: "from_id")
                
                HMPrint("SignNotifyAPI analysisReturnData ",dic )
                return dic
            }else {
                HMPrint("SignNotifyAPI parse failure")
                return  [:]
            }
        }
        return analysis
    }
}

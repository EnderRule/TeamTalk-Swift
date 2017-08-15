//
//  ReceiveMessageAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class ReceiveMessageAPI: DDUnrequestSuperAPI {
    
    func responseServiceID() -> Int32 {
        return Int32(SID_MSG)
    }
    
    func responseCommandID() -> Int32 {
        return Int32(IM_MSG_DATA)
    }
    
    func unrequestAnalysis() -> UnrequestAPIAnalysis! {
        let analysis:UnrequestAPIAnalysis = {(data) in
            if  let builder:Im.Message.ImmsgData.Builder = try? Im.Message.ImmsgData.Builder.fromJSONToBuilder(data: data!){
                if let res:Im.Message.ImmsgData = try? builder.build() {
                    
                    //Fixme: here, should return MTTMessageEntity
                    return res
                }else {
                    debugPrint("ReceiveMessageAPI builded failure")
                    return  nil
                }
            }else {
                debugPrint("ReceiveMessageAPI fromJSONToBuilder failure")
                return  nil
            }
        }
        return analysis
    }
}

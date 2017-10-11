//
//  DDReceiveGroupAddMemberAPI.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/17.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class DDReceiveGroupAddMemberAPI: DDUnrequestSuperAPI,DDAPIUnrequestScheduleProtocol {
    func responseServiceID() -> Int32 {
        return Int32(SID_GROUP)
    }
    
    func responseCommandID() -> Int32 {
        return Int32(IM_GROUP_CHANGE_MEMBER_REQ)
    }
    
    func unrequestAnalysis() -> UnrequestAPIAnalysis! {
        let analysis:UnrequestAPIAnalysis = {(data) in
            if let bodydata = DDDataInputStream.init(data: data){
                
                let result:Int32 = bodydata.readInt()
                
                if result != 0 {
                    return nil
                }else  {
                    let groupid = bodydata.readUTF() ?? ""
                    
                    if let entity = HMGroupsManager.shared.groupFor(ID: groupid){
                        let uidSets = NSMutableSet.init()
                        
                        let userCount = bodydata.readInt()
                        for _ in 0..<userCount {
                            uidSets.add(bodydata.readUTF() ?? "")
                        }
                        entity.groupUserIds = uidSets.allObjects as? [String] ?? []
                        return entity
                    }else{
                        return nil
                    }
                }
            }
            return nil
        }
        return analysis
    }
}

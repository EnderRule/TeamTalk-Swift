//
//  HMGroupsManager.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/10/10.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

//import UIKit

class HMGroupsManager: NSObject {
    static let shared:HMGroupsManager = HMGroupsManager()
    
    var allGroups:[String: MTTGroupEntity] = [:]
    
    func loadAllGroup(completion:(()->Void)?){
    
        MTTGroupEntity.db_query(predicate: nil , sortBy: "objID", sortAscending: true , offset: 0, limitCount: 0, success: { (groups ) in
            debugPrint("db load all user count \(groups.count)")
            
            if groups.count > 0 {
                for obj in  groups.enumerated(){
                    if let group:MTTGroupEntity = obj.element as? MTTGroupEntity{
                        self.add(group: group)
                    }
                }
            }
            completion?()
            
        }) { (error ) in
            completion?()
        }
    }

    func add(group:MTTGroupEntity){
        allGroups.updateValue(group, forKey: group.objID)
    }
    
    func groupFor(ID:String,completion:@escaping ((MTTGroupEntity?) ->Void)){
        if let group = allGroups[ID] {
            completion(group)
        }else{
            let groupid = MTTGroupEntity.pbIDFrom(localID: ID)
            let request = GetGroupInfoAPI.init(groupID: groupid, groupVersion: 0)
            request.request(withParameters: [:], completion: { (response, error ) in
                if let group = (response as? [MTTGroupEntity] ?? []).first{
                    
                    self.add(group: group)
                    completion(group)
                }else{
                    completion(nil)
                }
            })
        }
    }
}



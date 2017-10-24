//
//  HMGroupsManager.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/10/10.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

//import UIKit

public class HMGroupsManager: NSObject {
    public static let shared:HMGroupsManager = HMGroupsManager()
    
    var allGroups:[String: MTTGroupEntity] = [:]
    
    
    public func loadAllLocalGroup(completion:(()->Void)?){
    
        MTTGroupEntity.dbQuery(whereStr: nil , orderFields: "objID asc", offset: 0, limit: 0, args: []) { (groups , error ) in
//            HMPrint("db load all groups count \(groups.count)")
            
            if groups.count > 0 {
                for obj in  groups.enumerated(){
                    if let group:MTTGroupEntity = obj.element as? MTTGroupEntity{
                        self.add(group: group)
                    }
                }
            }
            completion?()
        }
    }

    public func cleanData(){
        allGroups.removeAll()
    }
    public func add(group:MTTGroupEntity){
        allGroups.updateValue(group, forKey: group.objID)
    }
    
    public func groupFor(ID:String)->MTTGroupEntity?{
        if let group = allGroups[ID] {
            return group
        }else{
            
            var target:MTTGroupEntity?
            DispatchQueue.global().sync {
                
                let groupid = MTTGroupEntity.pbIDFrom(localID: ID)
                let request = GetGroupInfoAPI.init(groupID: groupid, groupVersion: 0)
                request.request(withParameters: [:], completion: { (response, error ) in
                    if let group = (response as? [MTTGroupEntity] ?? []).first{
                        self.add(group: group)
                        target = group
                        group.dbSave(completion: nil)
                    }
                })
            }
            return target
        }
    }
    
    
    public var groups:[MTTGroupEntity] {
        get{
            var temp:[MTTGroupEntity] = []
            
            if self.allGroups.count == 0 {
                DispatchQueue.global().sync {
                    self.loadAllLocalGroup(completion: {
                        for obj in self.allGroups.values{
                            temp.append(obj)
                        }
                    })
                    
                }
            }else{
                for obj in allGroups.values{
                    temp.append(obj)
                }
            }
            return temp
        }
    }
}



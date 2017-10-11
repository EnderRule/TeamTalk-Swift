//
//  HMUsersManager.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/10/10.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

//import UIKit

class HMUsersManager: NSObject {

    static let shared:HMUsersManager = HMUsersManager()
    
    var allUsers:[String:MTTUserEntity] = [:]
    
    var allGroups:[String:MTTGroupEntity] = [:]
    
    /**
     *  登录成功后获取所有用户
     *
     *  @param completion 异步执行的block
     */
    
    func cleanData(){
        self.allUsers.removeAll()
        self.allGroups.removeAll()
    }
    
    func add(user:MTTUserEntity){
        if user.isValided{
            allUsers.updateValue(user , forKey: user.objID)
        }
    }
    
    func userFor(ID:String)->MTTUserEntity?{
        
        if allUsers.count <= 0 {
            var  user:MTTUserEntity?
            
            DispatchQueue.global().sync {
                self.loadAllUser {
                    user = self.allUsers[ID]
                }
            }
            return user
        }else{
            return allUsers[ID]
        }
    }
    
    func add(group:MTTGroupEntity){
        allGroups.updateValue(group , forKey: group.objID)
    }
    func groupFor(ID:String)->MTTGroupEntity?{
        if let group = allGroups[ID] {
            return group
        }else{
            //Fixme: should trying to load group from server
            
            return nil
        }
    }
    
    func loadAllUser(completion:(()->Void)?){

        if DEBUGMode{
            MTTUserEntity.db_query(predicate: nil , sortBy: "objID", sortAscending: true , offset: 0, limitCount: 0, success: { (users ) in
                debugPrint("test user query count \(users.count)")
                for obj  in users {
                    if let user:MTTUserEntity = obj as? MTTUserEntity{
                        debugPrint("user id ",user.objID)
                    }
                }
            }) { (error ) in
                debugPrint("test user query error \(error)")
            }
        }
        
        let kLastUpdate:String = AllUserAPI.kResultLastUpdateTime
        var localUpdateTime:Int = UserDefaults.standard.integer(forKey: kLastUpdate)
        
        let lock = NSCondition.init()
        lock.lock()
        
        var dbfinish:Bool = false
        MTTUserEntity.db_query(predicate: nil , sortBy: "objID", sortAscending: true , offset: 0, limitCount: 0, success: { (users ) in
            debugPrint("db load all user count \(users.count)")
            
            if users.count > 0 {
                for obj in  users.enumerated(){
                    if let user:MTTUserEntity = obj.element as? MTTUserEntity{
                        self.add(user: user)
                    }
                }
                completion?()
            }else{
                localUpdateTime = 0
            }
            
            dbfinish = true
        }) { (error ) in
            debugPrint("db load all user fail: ",error )
            
            localUpdateTime = 0
            dbfinish = true
        }
        while !dbfinish {
            //            debugPrint("lock wait() ")
            lock.wait()
        }
        
        lock.unlock()
        //        debugPrint("lock final unlock  ")
        
        let api2 = AllUserAPI.init(lastUpdateTime: localUpdateTime)
        api2.request(withParameters: [:]) { (response , error ) in
            if let dic = response as? [String:Any] {
                let rsversion:Int = dic[kLastUpdate] as? Int ?? 0
                UserDefaults.standard.set(rsversion, forKey: kLastUpdate)
                
                let users:[MTTUserEntity] = dic[ AllUserAPI.kResultUserList] as? [MTTUserEntity] ?? []
                for obj in  users.enumerated(){
                    self.add(user: obj.element)
                }
                completion?()
            }
        }
        
    }
    
}

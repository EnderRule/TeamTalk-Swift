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
    
    private var allUsers:[String:MTTUserEntity] = [:]
    
    func cleanData(){
        self.allUsers.removeAll()
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
    
    var users:[MTTUserEntity] {
        get{
            var temp:[MTTUserEntity] = []

            if self.allUsers.count == 0 {
                DispatchQueue.global().sync {
                    self.loadAllUser(completion: { 
                        for obj in self.allUsers.values{
                            temp.append(obj)
                        }
                    })
                }
            }else{
                for obj in allUsers.values{
                    temp.append(obj)
                }
            }
            return temp
        }
    }
    
    func loadAllUser(completion:(()->Void)?){
        
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
                        if user.isValided {
                            self.add(user: user)
                        }else{
                            user.db_delete(complettion: nil)
                        }
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

//
//  HMLoginManager.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/31.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

@objc protocol HMLoginManagerDelegate {
    
    func loginSuccess(user:MTTUserEntity)
    func loginFailure(error:String)
    
    
    @objc optional func reloginSuccess()
    @objc optional func reloginFailure(error:String)
}

class HMLoginManager: NSObject {

    static let shared:HMLoginManager = HMLoginManager()
    
    private var httpServer: DDHttpServer = DDHttpServer.init()
    private var msgServer:DDMsgServer = DDMsgServer.init()
    private var tcpServer:DDTcpServer = DDTcpServer.init()
    private var token:String = ""
    
    private var lastLoginUserID  :String = ""
    private var lastLoginUserName:String = ""
    private var lastLoginPassword:String = ""
    
    private var priorIP:String = ""
    private var priorport:Int = 0
    private var reloginning:Bool = false
    
    private var delegates:[HMLoginManagerDelegate] = []
    
    func loginWith(userName:String,password:String,success:@escaping ((MTTUserEntity)->Void),failure:@escaping ((String)->Void)){
        httpServer.getMsgIp({ [weak self] (dic ) in
            let json = JSON.init(dic ?? [:])
            let code = json["code"].int ?? 1
            if code == 0 {
                let ip = json["priorIP"].stringValue
                let port = json["port"].intValue
                self?.priorIP = ip
                self?.priorport = port
                
                MTTUtil.setMsfsUrl(json["msfsPrior"].stringValue)
                self?.tcpServer.loginTcpServerIP(ip, port: port, success: {
                    let clientVersion:String = "iOS/\(APP_VERSION)-\(APP_BUILD_VERSION)"
                    let clientType:Int = 17
                    let parameters:[Any] = [userName,password,clientVersion,clientType]
                    
                    let api = LoginAPI.init()
                    api.request(with: parameters, completion: { (response , error ) in
                        if let dic = response as? [AnyHashable:Any]{
                            let json2 = JSON.init(dic)
                            
                            debugPrint("\(ip)  \(port)  登入驗證  # ### \(dic)  \(json2["user"].object)")

                            
                            if let user:MTTUserEntity = dic["user"] as? MTTUserEntity {
                                debugPrint("登入驗證成功 # ###")
                                self?.lastLoginUserName = userName
                                self?.lastLoginPassword = password
                                self?.reloginning = true

                                DDClientState.shareInstance().userState = .online
                                RuntimeStatus.instance().user = user
                                RuntimeStatus.instance().userName = userName
                                RuntimeStatus.instance().token = password
                                RuntimeStatus.instance().autoLogin = true
                                
                                MTTDatabaseUtil.instance().openCurrentUserDB()
                                
                                self?.loadAllUser {
                                    if SpellLibrary.instance().isEmpty(){
                                        dispatch_globle(after: 0, task: { 
                                            for user in DDUserModule.shareInstance().getAllMaintanceUser() as? [MTTUserEntity] ?? []{
                                                SpellLibrary.instance().addSpellFor(user)
                                                SpellLibrary.instance().addDeparmentSpellFor(user )
                                            }
                                            for group in DDGroupModule.instance().getAllGroups() as? [MTTGroupEntity] ?? []{
                                                
                                                SpellLibrary.instance().addSpellFor(group)
                                            }
                                        })
                                    }
                                }
                                
                                SessionModule.instance().loadLocalSession({ (isok ) in })
                                
                                HMNotification.userLoginSuccess.postWith(obj: user , userInfo: nil )
                                
                                success(user)
                            }else{
                                var rstr = json["resultString"].stringValue
                                if rstr.length <= 0 {
                                    rstr = "登入失敗：code = \(json2["resultCode"])"
                                }
                                failure(rstr)
                            }
                            
                            
                        }else{
                            failure("登錄驗證失敗")
                        }
                    })
                    
                }, failure: { 
                    failure("连接消息服务器失败")
                })
            }else{
                failure("连接消息服务器失败")
            }
        }) { (error ) in
            failure("连接消息服务器失败")
        }
    }
    
    func relogin(success:@escaping ((MTTUserEntity)->Void),failure:@escaping ((String)->Void)){
        if DDClientState.shareInstance().userState == .offLine && lastLoginUserName.length > 0 && lastLoginPassword.length > 0 {
            self .loginWith(userName: lastLoginUserName, password: lastLoginPassword, success: { (user ) in
                HMNotification.userReloginSuccess.postWith(obj: user , userInfo: nil )
                success(user)
            }, failure: { (error ) in
                let error = "重新登陆失败".appending( error)
                HMNotification.userReloginFailure.postWith(obj: error, userInfo: nil )
                failure(error)
            })
        }
    }
    
    
    /**
     *  登录成功后获取所有用户
     *
     *  @param completion 异步执行的block
     */
    
    private func loadAllUser(completion:@escaping (()->Void)){
    
        let key:String = "alllastupdatetime"
        var version:Int = UserDefaults.standard.integer(forKey: key)
        
        MTTDatabaseUtil.instance().getAllUsers { (contacts , error ) in
            if contacts != nil && contacts!.count > 0 {
                for obj in  contacts!.enumerated(){
                    if let user:MTTUserEntity = obj.element as? MTTUserEntity{
                        DDUserModule.shareInstance().addMaintanceUser(user)
                    }
                }
                completion()
                
            }else{
                version = 0
                let api = AllUserAPI.init()
                api.request(with: [0], completion: { (response, error ) in
                    if let dic = response as? [String:Any] {
                        let rsversion:Int = dic[key] as? Int ?? 0
                        UserDefaults.standard.set(rsversion, forKey: key)
                        
                        let users:[MTTUserEntity] = dic["userlist"] as? [MTTUserEntity] ?? []
                        MTTDatabaseUtil.instance().insertUsers(users, completion: { ( error ) in   })
                        dispatch_globle(after: 0, task: {
                            for obj in  users.enumerated(){
                                DDUserModule.shareInstance().addMaintanceUser(obj.element)
                            }
                            
                            dispatch(after: 0, task: { 
                                completion()
                            })
                        })
                    }
                })
                
            }
        }
        
        let api2 = AllUserAPI.init()
        api2.request(with: [version]) { (response , error ) in
            if let dic = response as? [String:Any] {
                let rsversion:Int = dic[key] as? Int ?? 0
                UserDefaults.standard.set(rsversion, forKey: key)
                
                let users:[MTTUserEntity] = dic["userlist"] as? [MTTUserEntity] ?? []
                if users.count > 0 {
                    MTTDatabaseUtil.instance().insertUsers(users, completion: { (error ) in
                        print("login load all users ")
                    })
//                    MTTDatabaseUtil.instance().insertUsers(users, completion: { ( error ) in   })
                    dispatch_globle(after: 0, task: {
                        for obj in  users.enumerated(){
                            DDUserModule.shareInstance().addMaintanceUser(obj.element)
                        }
                        
                    })
                }
                
            }
            
        }
        
    }
    
}

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
    private var priorport:String = ""
    private var reloginning:Bool = false
    
    private var delegates:[HMLoginManagerDelegate] = []
    
    func loginWith(userName:String,password:String,success:@escaping ((MTTUserEntity)->Void),failure:@escaping ((String)->Void)){
        
        
    
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
    
//        let version:Int = UserDefaults.standard.integer(forKey: "alllastupdatetime")
        
        MTTDatabaseUtil.instance().getAllUsers { (contacts , error ) in
            if contacts != nil && contacts!.count > 0 {
                for obj in  contacts!.enumerated(){
                    if let user:MTTUserEntity = obj.element as? MTTUserEntity{
                        DDUserModule.shareInstance().addMaintanceUser(user)
                    }
                }
                completion()
                
            }else{
                
                
            }
        }
        
        
        
    }
    
}

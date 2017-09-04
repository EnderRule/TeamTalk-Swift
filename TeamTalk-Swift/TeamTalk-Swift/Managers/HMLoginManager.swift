//
//  HMLoginManager.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/31.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

@objc enum HMLoginState:Int {
    case online = 0
    case kickout            //被挤下线
    case offLine
    case offLineInitiative  //主动下线
    case logining           //正在连线
}

@objc enum HMNetworkState:Int{
    case wifi
    case G3
    case G2
    case disconnect
}
@objc enum HMSocketState:Int{
    case linkingLoginServer
    case linkingMessageServer
    case disconnect
}


@objc protocol HMLoginManagerDelegate {
    
    func loginSuccess(user:MTTUserEntity)
    func loginFailure(error:String)
    @objc optional func reloginSuccess()
    @objc optional func reloginFailure(error:String)
    @objc optional func loginStateChanged(state:HMLoginState)

    @objc optional func networkStateChanged(state:HMNetworkState)
    @objc optional func socketStateChangeD(state:HMSocketState)
    
}

class HMLoginManager: NSObject {

    static let shared:HMLoginManager = HMLoginManager()
    
    var currentUser:MTTUserEntity{
        get{
            return s_currentUser
        }
    }
    private var s_currentUser:MTTUserEntity = MTTUserEntity.init()
    
    var loginState:HMLoginState{
        get{
            return s_loginState
        }
    }
    var networkState:HMNetworkState{
        get {
            return s_networkState
        }
    }
    private var s_networkState:HMNetworkState = .disconnect
    private var s_loginState:HMLoginState = .offLine
    
    private var reachability:DDReachability = DDReachability.forInternetConnection()
    
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
    
    
    override init() {
        super.init()
        
        self.registerAPI()
        
        
        
        
        NotificationCenter.default.addObserver(self , selector: #selector(self.n_receiveReachabilityChanged(notification:)), name: Notification.Name.init("kDDReachabilityChangedNotification"), object: nil )
        
        reachability.startNotifier()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self )
    }
    
    func registerAPI(){
        let receiveKickOffApi = ReceiveKickOffAPI.init()
        receiveKickOffApi.registerAPI { (object, error ) in
            HMNotification.userKickouted.postWith(obj: object, userInfo: nil )
        }
        
        let signaturechange = SignNotifyAPI.init()
        signaturechange.registerAPI { (object , error ) in
            HMNotification.userSignatureChanged.postWith(obj: object, userInfo: nil )
        }
        
        let pclogin = LoginStatusNotifyAPI.init()
        pclogin.registerAPI { (object , error ) in
            HMNotification.pcLoginStatusChanged.postWith(obj: object, userInfo: nil )
        }
    }
    
    func checkUpdateVersion(){
    
        
    }
    
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
                    })
                    dispatch_globle(after: 0, task: {
                        for obj in  users.enumerated(){
                            DDUserModule.shareInstance().addMaintanceUser(obj.element)
                        }
                        
                    })
                }
                
            }
            
        }
        
    }
    
    
    @objc private func n_receiveReachabilityChanged(notification:Notification){
        if let reach:DDReachability = notification.object as? DDReachability{
            let networkstate = reach.currentReachabilityStatus()
            
            switch networkstate {
            case .NotReachable:
                self.s_networkState = .disconnect
                 break
            case .ReachableViaWiFi:
                self.s_networkState = .wifi
                break
            case .ReachableViaWWAN:
                self.s_networkState = .G3
            }
            
        }
        
        
    }
}

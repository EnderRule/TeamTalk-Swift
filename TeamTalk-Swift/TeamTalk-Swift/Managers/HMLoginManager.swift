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

func currentUserID()->String{
    return HMLoginManager.shared.currentUserID
}
func currentUserName()->String{
    return HMLoginManager.shared.currentUserName
}
func currentUser()->MTTUserEntity{
    return HMLoginManager.shared.currentUser
}

class HMLoginManager: NSObject {

    static let shared:HMLoginManager = HMLoginManager()
    
    var currentUser:MTTUserEntity{
        get{
            return s_currentUser
        }
    }
    
    var loginState:HMLoginState{
        get{
            return s_loginState
        }
        set{
            self.s_loginState = newValue
        }
    }
    var networkState:HMNetworkState{
        get {
            return s_networkState
        }
    }
    var pushTtoken:String{
        set{
            UserDefaults.standard.setValue(newValue, forKey: "im.HMCurrentPushToken")
            UserDefaults.standard.synchronize()
        }
        get {
            return  UserDefaults.standard.object(forKey: "im.HMCurrentPushToken") as? String ?? ""
        }
    }
    var currentUserID  :String{
        set{
            UserDefaults.standard.setValue(newValue, forKey: "im.HMCurrentUserID")
            UserDefaults.standard.synchronize()
        }
        get {
            return  UserDefaults.standard.object(forKey: "im.HMCurrentUserID") as? String ?? ""
        }
    }
    var currentUserName:String{
        set{
            UserDefaults.standard.setValue(newValue, forKey: "im.HMCurrentUserName")
            UserDefaults.standard.synchronize()
        }
        get {
            return  UserDefaults.standard.object(forKey: "im.HMCurrentUserName") as? String ?? ""
        }
    }
    var currentPassword:String{
        set{
            UserDefaults.standard.setValue(newValue, forKey: "im.HMCurrentUserPassword")
            UserDefaults.standard.synchronize()
        }
        get {
            return  UserDefaults.standard.object(forKey: "im.HMCurrentUserPassword") as? String ?? ""
        }
    }
    var shouldAutoLogin:Bool{
        set{
            UserDefaults.standard.setValue(newValue, forKey: "im.HMShouldAutoLogin")
            UserDefaults.standard.synchronize()
        }
        get {
            return  UserDefaults.standard.bool(forKey: "im.HMShouldAutoLogin")
        }
    }
    var msfsUrl:String {  //消息服务器之文件服务器的地址 ，用于上传图片、文件
        set{
            UserDefaults.standard.setValue(newValue, forKey: "im.HMMessageServerFileServer")
            UserDefaults.standard.synchronize()
        }
        get {
            return  UserDefaults.standard.object(forKey: "im.HMMessageServerFileServer") as? String ?? ""
        }
    }
    
    var serverTime:TimeInterval {
        get{
            return s_serverTime
        }
    }
    
    private var s_serverTime:TimeInterval = Date().timeIntervalSince1970
    private var s_currentUser:MTTUserEntity = MTTUserEntity.init()
    private var s_networkState:HMNetworkState = .disconnect
    private var s_loginState:HMLoginState = .offLine{
        didSet{
//            debugPrint("HMLoginManager login state didSet \(self.s_loginState) ")
            self.loginStateChangeHandler()
        }
    }
    
    private var reachability:DDReachability = DDReachability.forInternetConnection()
    
    private var httpServer: DDHttpServer = DDHttpServer.init()
    private var msgServer:DDMsgServer = DDMsgServer.init()
    private var tcpServer:DDTcpServer = DDTcpServer.init()
    
    private var priorIP:String = ""
    private var priorport:Int = 0
    private var reloginning:Bool = false
    
    private var delegates:[HMLoginManagerDelegate] = []
    
    override init() {
        super.init()
        
        self.registerAPI()
        
        
        NotificationCenter.default.addObserver(self , selector: #selector(self.n_receiveReachabilityChanged(notification:)), name: Notification.Name.init("kDDReachabilityChangedNotification"), object: nil )
        NotificationCenter.default.addObserver(self , selector: #selector(self.n_receiveServerHeartBeat), name: HMNotification.serverHeartBeat.notificationName(), object: nil )
        
        reachability.startNotifier()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self )
    }
    
    func setup(){
    }
    
     private func registerAPI(){
        
        ////接收踢出
        let receiveKickOffApi = ReceiveKickOffAPI.init()
        receiveKickOffApi.registerAPI {[weak self ] (object, error ) in
            HMNotification.userKickouted.postWith(obj: object, userInfo: nil )
           
            for delegate in  self?.delegates ?? []{
                delegate.loginStateChanged?(state: HMLoginState.kickout)
            }
            
        }
         //接收签名改变通知
        let signaturechange = SignNotifyAPI.init()
        signaturechange.registerAPI { (object , error ) in
            HMNotification.userSignatureChanged.postWith(obj: object, userInfo: nil )
        }
        //接收pc端登陆状态变化通知
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
                
                
                self?.msfsUrl = json["msfsPrior"].stringValue
                
//                debugPrint(json["msfsPrior"].stringValue,"fffffff   ",self?.msfsUrl)
                
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
                                
                                
                                if json["serverTime"].doubleValue > 3600 {
                                    self?.s_serverTime = json["serverTime"].doubleValue
                                    self?.startCountServerTime()
                                }
                                
                                self?.s_loginState = .online

                                self?.s_currentUser = user
                                self?.currentUserName = userName
                                self?.currentPassword = password
                                self?.shouldAutoLogin = true
                                
                                self?.reloginning = true

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
        if self.loginState == .offLine && currentUserName.length > 0 && currentPassword.length > 0 {
            self .loginWith(userName: currentUserName, password: currentPassword, success: { (user ) in
                HMNotification.userReloginSuccess.postWith(obj: user , userInfo: nil )
                
                success(user)
            }, failure: { (error ) in
                let error = "重新登陆失败".appending( error)
                HMNotification.userReloginFailure.postWith(obj: error, userInfo: nil )
                failure(error)
            })
        }
    }
    
    func logout(){
        
        self.s_currentUser = MTTUserEntity.init()
        self.currentUserID = ""
        self.currentUserName = ""
        self.shouldAutoLogin = false
        
        DDMessageModule.shareInstance().removeAllUnreadMessages()
        SessionModule.instance().clearSession()
        DDTcpClientManager.instance().disconnect()
        
        self.s_loginState = .offLineInitiative
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
//                        MTTDatabaseUtil.instance().insertUsers(users, completion: { ( error ) in   })
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
//                    MTTDatabaseUtil.instance().insertUsers(users, completion: { (error ) in   })
                    dispatch_globle(after: 0, task: {
                        for obj in  users.enumerated(){
                            DDUserModule.shareInstance().addMaintanceUser(obj.element)
                        }
                        
                    })
                }
                
            }
            
        }
        
    }
    
    private func loginStateChangeHandler(){
        
        debugPrint("loginState ChangeHandler  \(self.s_loginState.rawValue)")
        switch (self.s_loginState)
        {
        case .kickout:
            
            self.p_stopCheckServerHeartBeat()
            self.p_stopHeartBeat()
            
            break;
        case .offLine:
            
            self.p_stopCheckServerHeartBeat()
            self.p_stopHeartBeat()
            self.p_startRelogin()
            
            break;
        case .offLineInitiative:

            self.p_stopCheckServerHeartBeat()
            self.p_stopHeartBeat()
            break;
        case .online:
            self.p_startCheckServerHeartBeat()
            self.p_startHeartBeat()
            break;
        case .logining:
            
            break;
        }
        
    }
    
    
    //维护服务器时间
    private var serverTimeTimer:Timer?
    private func startCountServerTime(){
        self.serverTimeTimer?.invalidate()
        self.serverTimeTimer = nil
        
        self.serverTimeTimer = Timer.scheduledTimer(timeInterval: 1, target: self , selector: #selector(self.serverTimeCounter), userInfo: nil , repeats: true  )
        self.serverTimeTimer?.fire()
        
    }
    @objc private func serverTimeCounter(){
        self.s_serverTime += 1
    }
    
    private var sendHeartBeatTimer:Timer?
    private var reloginTimer:Timer?
    private var checkServerHeartBeatTimer:Timer?
    
    private var receivedServerHeart:Bool = false
    private var reloginInterval:Int = 0
    private var reloginTimeN:Int = 0
    private var powN:Int = 0
    
    private func p_startCheckServerHeartBeat(){
        self.checkServerHeartBeatTimer?.invalidate()
        
        self.checkServerHeartBeatTimer = Timer.scheduledTimer(timeInterval: 60, target: self , selector: #selector(self.checkServerHeartBeat(timer:)), userInfo: nil , repeats: true)
        self.checkServerHeartBeatTimer?.fire()
    }
    
    private func p_startHeartBeat(){
        self.sendHeartBeatTimer?.invalidate()
        
        self.sendHeartBeatTimer = Timer.scheduledTimer(timeInterval: 30, target: self , selector: #selector(self.sendHeartBeat(timer:)), userInfo: nil , repeats: true )
        self.sendHeartBeatTimer?.fire()
    }
    private func p_startRelogin(){
        self.reloginTimer?.invalidate()  //取消之前的定时
        
        self.reloginTimer = Timer.scheduledTimer(timeInterval: 5, target: self , selector: #selector(self.relogin(timer:)), userInfo: nil , repeats: true)
        self.reloginTimer?.fire()
    }
    
    private func p_stopHeartBeat(){
        self.sendHeartBeatTimer?.invalidate()
        self.sendHeartBeatTimer = nil
    }
    private func p_stopCheckServerHeartBeat(){
        self.checkServerHeartBeatTimer?.invalidate()
        self.checkServerHeartBeatTimer = nil
    }
    private func p_stopRelogin(){
        self.reloginTimer?.invalidate()
        self.reloginTimer = nil
    }
    
    @objc private func n_receiveServerHeartBeat(){
        debugPrint(" ********** server 嘣 ***********")

        self.receivedServerHeart = true
    }
    
    @objc private func sendHeartBeat(timer:Timer){
        debugPrint(" ********** send 嘣 ***********")
        HeartbeatAPI.init().request(with: nil) { (object , error ) in }
    }
    @objc private func checkServerHeartBeat(timer:Timer){

        if self.receivedServerHeart {
            self.receivedServerHeart = false
            
            self.p_stopRelogin()
        }else{
            debugPrint("太久没收到服务器端 心跳")
            
            self.p_stopCheckServerHeartBeat()
            self.p_stopHeartBeat()
            
            self.p_startRelogin()
        }
    }
    
    
    @objc private func relogin(timer:Timer){
        reloginTimeN += 1
        
        debugPrint("HMloginmanager relogin")
        
        if reloginTimeN >= self.reloginInterval {
            
            self.relogin(success: { (user ) in
                self.reloginTimer?.invalidate()
                self.reloginTimer = nil
                
                self.reloginTimeN = 0
                self.reloginInterval = 0
                self.powN = 0
                
                self.s_loginState = .online
                HMNotification.userReloginSuccess.postWith(obj: user , userInfo: nil )
                
            }, failure: { (error ) in
                if error == "未登录"{
                    self.reloginTimer?.invalidate()
                    self.reloginTimer = nil
                    
                    self.reloginTimeN = 0
                    self.reloginInterval = 0
                    self.powN = 0
                    
                }else{
                    self.powN += 1
                    self.reloginTimeN = 0
                    self.reloginInterval = Int( pow(2.0 , Double(self.powN)) )
                }
            })
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
            
            //断开链接时，下线
            if self.s_networkState == .disconnect  {
                self.s_loginState = .offLine
            }else{
                //网络变化时,重登计时器无效、且用户不处于 在线/踢出/主动下线 其中之一，才需要启动重登
                let shouldRelogin:Bool = self.reloginTimer == nil
                    && !self.reloginTimer!.isValid
                    && self.s_loginState != .online
                    && self.s_loginState != .kickout
                    && self.s_loginState != .offLineInitiative
                
                if shouldRelogin {
                    self.reloginInterval = 0
                    
                    self.p_startRelogin()
                }
            }
        }
    }
}

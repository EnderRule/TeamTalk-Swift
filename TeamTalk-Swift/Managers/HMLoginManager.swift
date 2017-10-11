//
//  HMLoginManager.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/31.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

//import UIKit
import AFNetworking


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

func HMCurrentUser()->MTTUserEntity{
    return HMLoginManager.shared.currentUser
}

class HMLoginManager: NSObject,DDTcpClientManagerDelegate {

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
    private var s_currentUser:MTTUserEntity = MTTUserEntity.newNotInertObj() as! MTTUserEntity
    private var s_networkState:HMNetworkState = .disconnect
    private var s_loginState:HMLoginState = .offLine{
        didSet{
//            debugPrint("HMLoginManager login state didSet \(self.s_loginState) ")
            self.loginStateChangeHandler()
        }
    }

    private var reachability:DDReachability = DDReachability.forInternetConnection()
    private var getMsgIPManager:AFHTTPSessionManager = AFHTTPSessionManager.init()
    private var priorIP:String = ""
    private var priorport:Int = 0
    private var reloginning:Bool = false
    
    
    private var delegates:[HMLoginManagerDelegate] = []
    
    override init() {
        super.init()
        
        self.registerAPI()
        
        self.getMsgIPManager.responseSerializer.acceptableContentTypes = NSSet.init(objects: "text/html") as? Set<String>

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
    
    
    func getMsgIP(success:@escaping (([AnyHashable:Any])->Void),failure:@escaping ((String)->Void)){
        
        self.getMsgIPManager.get(SERVER_Address, parameters: nil , progress: nil , success: { (task , responseObject ) in
            
            let json = JSON.init(responseObject ?? [:])
            let dic = json.dictionaryObject ?? [:]
            if dic.count > 0{
                success(dic)
            }else{
                failure("连接消息服务器失败 code:-1")
            }
        }) { (task , error ) in
            failure(error.localizedDescription)
        }
    }
    
    
    private var  tcpConnectSuccess:(()->Void)?
    private var  tcpConnectFailure:((String)->Void)?
    private var  tcpIsConnecting:Bool = false
    private var  tcpConnectTimes:Int = 0
    private let tcpConnectTimeOutInterval:TimeInterval = 10
    private func  connect(ip:String,port:Int,success:@escaping (()->Void),failure:@escaping ((String)->Void)){
        
        if !tcpIsConnecting{
            tcpConnectTimes += 1
            tcpIsConnecting = true
            self.tcpConnectSuccess = success
            self.tcpConnectFailure = failure
 
            DDTcpClientManager.instance().disconnect()
            DDTcpClientManager.instance().delegate = self
            DDTcpClientManager.instance().connect(ip , port: port, status: 1)
            
            //超时处理
            let nowTime = tcpConnectTimes
            dispatch(after: tcpConnectTimeOutInterval, task: { 
                if self.tcpIsConnecting && nowTime == self.tcpConnectTimes {
                    self.tcpIsConnecting = false
                   
                    self.tcpConnectFailure?("連接超時")
                    self.tcpConnectFailure = nil
                    self.tcpConnectSuccess = nil
                }
            })
        }
    }
    
    internal func tcpClientConnectSuccess() {
        if self.tcpIsConnecting{
            self.tcpIsConnecting = false
            
            dispatch(after: 0, task: { 
                 self.tcpConnectSuccess?()
                self.tcpConnectSuccess = nil
                self.tcpConnectFailure = nil
            })
        }
    }
    internal func tcpClientConnectFailure() {
        if self.tcpIsConnecting{
            self.tcpIsConnecting = false
            
            dispatch(after: 0, task: {
                self.tcpConnectFailure?("連接消息服務器失敗-3")
                self.tcpConnectFailure = nil
                self.tcpConnectSuccess = nil
            })
        }
    }
    internal func tcpClientReceiveServerHeartBeat() {
        self.n_receiveServerHeartBeat()
    }

    internal func loginWith(userName:String,password:String,success:@escaping ((MTTUserEntity)->Void),failure:@escaping ((String)->Void)){
        
        self.getMsgIP(success: { (dic ) in
            let json = JSON.init(dic)
            let code = json["code"].int ?? 1
            if code == 0 {
                let ip = json["priorIP"].stringValue
                let port = json["port"].intValue
                self.priorIP = ip
                self.priorport = port
                self.msfsUrl = json["msfsPrior"].stringValue
                
                self.connect(ip: ip, port: port, success: { 
                    
                    let api = LoginAPI.init(name: userName, password: password)
                    api.request(withParameters: [:], completion:  { (response , error ) in
                        if let dic = response as? [String:Any]{
                            let json2 = JSON.init(dic)
                            
                            debugPrint("登入IP/端口\(ip)/\(port)  result:\(dic)")
                            if let user:MTTUserEntity = dic[LoginAPI.kResultUser] as? MTTUserEntity {
                                let time:TimeInterval = json2[LoginAPI.kResultServerTime].doubleValue
                                debugPrint("登入驗證成功   serverTime :\(time)")
                                if time > 3600.0 {
                                    self.s_serverTime = time
                                }
                                self.startCountServerTime()
                                self.s_loginState = .online
                                self.s_currentUser = user
                                self.currentUserName = userName
                                self.currentPassword = password
                                self.shouldAutoLogin = true
                                
                                self.reloginning = true
                                
                                MTTDatabaseUtil.instance().openCurrentUserDB()
                                
                                HMUsersManager.shared.loadAllUser(completion: nil)
                                
                                SessionModule.instance().loadLocalSession({ (isok ) in })
                                
                                HMNotification.userLoginSuccess.postWith(obj: user , userInfo: nil )
                                
                                self.sendPushtoken(token: self.pushTtoken)
                                
                                success(user)
                            }else{
                                var rstr = json[LoginAPI.kResultMessage].stringValue
                                if rstr.length <= 0 {
                                    rstr = "登入失敗：code = \(json2[LoginAPI.kResultCode])"
                                }
                                failure(rstr)
                            }
                        }else{
                            failure("登錄驗證失敗")
                        }
                    })
                }, failure: {(error)in
                    failure(error)
                })
            }else{
                failure("连接消息服务器失败 -2")
            }
        }) { (error ) in
            failure(error)
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
        self.s_loginState = .offLineInitiative

        self.s_currentUser = MTTUserEntity.newNotInertObj() as! MTTUserEntity
        self.currentUserID = ""
        self.currentUserName = ""
        self.shouldAutoLogin = false
        
        HMUsersManager.shared.cleanData()

        SessionModule.instance().clearSession()
        DDTcpClientManager.instance().delegate = nil
        DDTcpClientManager.instance().disconnect()
    
        self.s_loginState = .offLineInitiative
    }
    
    func sendPushtoken(token:String){
        debugPrint("call Send PushToken API ")
        let api =  SendPushTokenAPI.init(pushToken: self.pushTtoken)
        api.request(withParameters: [:], completion: { (obj , error ) in
        })
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
        
//        print("serverTime:\(Int(self.s_serverTime))  phoneTime:\(Int(Date().timeIntervalSince1970))")
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
        HeartbeatAPI.init().request(withParameters: nil) { (object , error ) in }
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

//
//  HMLoginManager.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/31.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

//import UIKit
import AFNetworking


@objc public enum HMLoginState:Int {
    case online = 0
    case kickout            //被挤下线
    case offLine
    case offLineInitiative  //主动下线
    case logining           //正在连线
}

@objc public enum HMNetworkState:Int{
    case wifi
    case G3
    case G2
    case disconnect
}
@objc public enum HMSocketState:Int{
    case linkingLoginServer
    case linkingMessageServer
    case disconnect
}


@objc public protocol HMLoginManagerDelegate {
    
    @objc optional func loginSuccess(user:MTTUserEntity)
    @objc optional func loginFailure(error:String)
    
    @objc optional func loginStateChanged(state:HMLoginState)
    
    @objc optional func networkStateChanged(state:HMNetworkState)
    @objc optional func socketStateChangeD(state:HMSocketState)
    
}

public class HMLoginManager: NSObject,DDTcpClientManagerDelegate {

    
    public static let shared:HMLoginManager = HMLoginManager()
    
    
    
    public var currentUser:MTTUserEntity{
        get{
            if !s_currentUser.isValided{
                if let user = HMUsersManager.shared.userFor(ID: self.currentUserID){
                    s_currentUser = user
                }
            }
            return s_currentUser
        }
    }
    
    public var loginState:HMLoginState{
        get{
            return s_loginState
        }
    }
    public var networkState:HMNetworkState{
        get {
            return s_networkState
        }
    }
    public var pushTtoken:String{
        set{
            UserDefaults.standard.setValue(newValue, forKey: "im.HMCurrentPushToken")
            UserDefaults.standard.synchronize()
        }
        get {
            return  UserDefaults.standard.object(forKey: "im.HMCurrentPushToken") as? String ?? ""
        }
    }
    public var currentUserID  :String{
        set{
            UserDefaults.standard.setValue(newValue, forKey: "im.HMCurrentUserID")
            UserDefaults.standard.synchronize()
        }
        get {
            return  UserDefaults.standard.object(forKey: "im.HMCurrentUserID") as? String ?? ""
        }
    }
     var currentLoginID:String{
        set{
            UserDefaults.standard.setValue(newValue, forKey: "im.HMCurrentUserName")
            UserDefaults.standard.synchronize()
        }
        get {
            return  UserDefaults.standard.object(forKey: "im.HMCurrentUserName") as? String ?? ""
        }
    }
     var currentLoginPwd:String{
        set{
            UserDefaults.standard.setValue(newValue, forKey: "im.HMCurrentUserPassword")
            UserDefaults.standard.synchronize()
        }
        get {
            return  UserDefaults.standard.object(forKey: "im.HMCurrentUserPassword") as? String ?? ""
        }
    }
    public var shouldAutoLogin:Bool{
        set{
            UserDefaults.standard.setValue(newValue, forKey: "im.HMShouldAutoLogin")
            UserDefaults.standard.synchronize()
        }
        get {
            return  UserDefaults.standard.bool(forKey: "im.HMShouldAutoLogin")
        }
    }
    public var msfsUrl:String {  //消息服务器之文件服务器的地址 ，用于上传图片、文件
        set{
            UserDefaults.standard.setValue(newValue, forKey: "im.HMMessageServerFileServer")
            UserDefaults.standard.synchronize()
        }
        get {
            return  UserDefaults.standard.object(forKey: "im.HMMessageServerFileServer") as? String ?? ""
        }
    }
    
    public var serverTime:TimeInterval {
        get{
            return s_serverTime
        }
    }
    
    private var s_serverTime:TimeInterval = Date().timeIntervalSince1970
    private var s_currentUser:MTTUserEntity = MTTUserEntity.init()
    
    private var s_networkState:HMNetworkState = .wifi
    private var s_loginState:HMLoginState = .offLine{
        didSet{
            self.loginStateChangeHandler()
        }
    }

    private var reachability:DDReachability = DDReachability.forInternetConnection()
    private var getMsgIPManager:AFHTTPSessionManager = AFHTTPSessionManager.init()
    private var priorIP:String = ""
    private var priorport:Int = 0
    private var reloginning:Bool = false
    
    
    public var delegate:HMLoginManagerDelegate?
    
    override init() {
        super.init()
        
        self.registerAPI()
        
        self.getMsgIPManager.responseSerializer.acceptableContentTypes = NSSet.init(objects: "text/html") as? Set<String>

        
        NotificationCenter.default.addObserver(self , selector: #selector(self.n_receiveReachabilityChanged(notification:)), name: Notification.Name.ddReachabilityChanged, object: nil )
        NotificationCenter.default.addObserver(self , selector: #selector(self.n_receiveServerHeartBeat), name: HMNotification.serverHeartBeat.notificationName(), object: nil )
        
        reachability.startNotifier()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self )
    }
         
     private func registerAPI(){
        
        ////接收踢出
        let receiveKickOffApi = ReceiveKickOffAPI.init()
        receiveKickOffApi.registerAPI { (object, error ) in
            HMNotification.userKickouted.postWith(obj: object, userInfo: nil )
           
            self.delegate?.loginStateChanged?(state: .kickout)
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
    private func getMsgIP(success:@escaping (([AnyHashable:Any])->Void),failure:@escaping ((String)->Void)){
        
        let serveraddress = HMConfigs.MsgServerAddress
        
        if serveraddress.characters.count < 5{
            HMPrint("get msgIP error: HMConfigs：消息服務器地址無效-\(serveraddress)")
            failure("HMConfigs：消息服務器地址無效 ")
            return
        }
        
        self.getMsgIPManager.get(serveraddress, parameters: nil , progress: nil , success: { (task , responseObject ) in
            
            let json = JSON.init(responseObject ?? [:])
            let dic = json.dictionaryObject ?? [:]
            if dic.count > 0{
                
                HMPrint("get msgIP:\(dic)")
                
                success(dic)
            }else{
                failure("连接消息服务器失败 code:-1")
            }
        }) { (task , error ) in
            HMPrint("get msgIP error:\(error.localizedDescription)")
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
    
    public func tcpClientConnectSuccess() {
        
        
        if self.tcpIsConnecting{
            self.tcpIsConnecting = false
            
            dispatch(after: 0, task: { 
                 self.tcpConnectSuccess?()
                self.tcpConnectSuccess = nil
                self.tcpConnectFailure = nil
            })
        }
        self.s_loginState = .online
        
    }
    public func tcpClientConnectFailure() {
        if self.tcpIsConnecting{
            self.tcpIsConnecting = false
            
            dispatch(after: 0, task: {
                self.tcpConnectFailure?("連接消息服務器失敗-3")
                self.tcpConnectFailure = nil
                self.tcpConnectSuccess = nil
            })
        }
        self.s_loginState = .offLine
        
    }
    public  func tcpClientReceiveServerHeartBeat() {
        self.n_receiveServerHeartBeat()
    }

    
    private func getAutoLoginUserPairs()->[String]{
    
        return UserDefaults.standard.stringArray(forKey: "HMLoginManager_AutoLoginPairs") ?? []
    }
    
    private func addAutoLoginPair(loginID:String,pwd:String,userID:String){
        var oldPairs = self.getAutoLoginUserPairs()
        oldPairs.append("\(loginID) \(pwd) \(userID)")
        
        UserDefaults.standard.setValue(oldPairs, forKey: "HMLoginManager_AutoLoginPairs")
        UserDefaults.standard.synchronize()
    }
    
    /// 自动登录，用于无网络状态时可以登入到本地聊天记录
    ///
    /// - Returns:
    public func autoLogin(ID:String,pwd:String){
        var existUserID:String = ""
        let oldPairs = self.getAutoLoginUserPairs()
        for obj in oldPairs{
            print("old pair:\(obj)")
            let pair = obj.components(separatedBy: " ")
            if pair.count == 3{
                if ID == pair[0] && pwd == pair[1]{
                    existUserID = pair[2]
                    break
                }
            }
        }
        
        if existUserID.characters.count > 0 {
            
            DispatchQueue.global().sync {
                self.openDB(userid: existUserID)
            }
            
            if let user = HMUsersManager.shared.userFor(ID: existUserID) {
                
                self.s_currentUser = user

                self.currentLoginID = ID
                self.currentLoginPwd = pwd
                self.shouldAutoLogin = true
                
                self.reloginning = true
                
                if self.reachability.isReachable(){
                
                    self.loginWith(loginID: ID, password: pwd, success: { (user ) in
                        
                    }, failure: { (error ) in
                        
                    })
                }
            }
        }
        
    }
    
    var myDBManager:HMDBManager = HMDBManager.init()

    private func openDB(userid:String){
        myDBManager.modelClasses = [MTTUserEntity.classForCoder(),MTTGroupEntity.classForCoder(),MTTMessageEntity.classForCoder(),MTTSessionEntity.classForCoder(),MTTMsgReadState.classForCoder()]
        myDBManager.openDB(userID: userid)
    }
    private func closeDB(){
        myDBManager.dataBaseQueue.close()
    }
    
    public  func loginWith(loginID:String,password:String,success:@escaping ((MTTUserEntity)->Void),failure:@escaping ((String)->Void)){
        
        if !self.reachability.isReachable(){
            self.autoLogin(ID: loginID, pwd: password)
            
            failure("网络连接已断开")
            return
        }
        
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
                    
                    let api = LoginAPI.init(name: loginID, password: password)
                    api.request(withParameters: [:], completion:  { (response , error ) in
                        if let dic = response as? [String:Any]{
                            let json2 = JSON.init(dic)
                            
                            HMPrint("登入IP/端口\(ip)/\(port)  result:\(dic)")
                            if let user:MTTUserEntity = dic[LoginAPI.kResultUser] as? MTTUserEntity {
                                let time:TimeInterval = json2[LoginAPI.kResultServerTime].doubleValue
                                if time > 3600.0 {
                                    self.s_serverTime = time
                                }
                                
                                self.s_currentUser = user
                                
                                HMPrint("登入驗證成功   serverTime :\(time) \(self.s_currentUser.objID) \(self.s_currentUser.name) \(self.s_currentUser.avatar) \(self.s_currentUser.nickName) \(self.currentUser)")

                                self.currentLoginID = loginID
                                self.currentLoginPwd = password
                                self.shouldAutoLogin = true

                                self.addAutoLoginPair(loginID: loginID, pwd: password, userID: user.userId)
                                
                                self.s_loginState = .online
                                self.startCountServerTime()

                                self.reloginning = true
                                
                                self.openDB(userid: user.userId)
                                
                                HMSessionModule.shared.loadLocalSession(completion: nil)
                                
                                
                                self.sendPushtoken()
                                
                                
                                HMUsersManager.shared.loadAllUser(completion: { 
                                    if let user = HMUsersManager.shared.userFor(ID: user.objID){
                                        self.s_currentUser = user
                                    }
                                })
                                
                                success(user)
                                self.delegate?.loginSuccess?(user: user)
                                HMNotification.userLoginSuccess.postWith(obj: user , userInfo: nil )

                            }else{
                                let error = "登入失敗：code = \(json2[LoginAPI.kResultCode]),\(json[LoginAPI.kResultMessage].stringValue)"
                                HMPrint(error)
                                
                                self.delegate?.loginFailure?(error: error)
                                failure(error)
                            }
                        }else{
                            let error = "登錄驗證失敗"
                            HMPrint(error)
                            self.delegate?.loginFailure?(error: error)

                            failure(error)
                        }
                    })
                }, failure: {(error)in
                    let errorMsg = "登入IP/端口 \(ip)/\(port) error:\(error)"
                    HMPrint(errorMsg)
                    
                    self.delegate?.loginFailure?(error: error)
                    failure(error)
                })
            }else{
                let error = "连接消息服务器失败 -2"
                HMPrint(error )
                self.delegate?.loginFailure?(error: error)
                
                failure(error )
            }
        }) { (error ) in
            HMPrint(error)
            self.delegate?.loginFailure?(error: error)

            failure(error)

        }
    }
    
    func relogin(success:@escaping ((MTTUserEntity)->Void),failure:@escaping ((String)->Void)){
        if self.loginState == .offLine && currentLoginID.length > 0 && currentLoginPwd.length > 0 {
            self .loginWith(loginID: currentLoginID, password: currentLoginPwd, success: { (user ) in
                HMNotification.userReloginSuccess.postWith(obj: user , userInfo: nil )
                
                success(user)
            }, failure: { (error ) in
                let error = "重新登陆失败".appending( error)
                HMNotification.userReloginFailure.postWith(obj: error, userInfo: nil )
                failure(error)
            })
        }
    }
    
    public  func logout(){
        self.s_loginState = .offLineInitiative

        self.s_currentUser = MTTUserEntity.init()
        self.currentUserID = ""
        self.currentLoginID = ""
        self.shouldAutoLogin = false
        
        HMUsersManager.shared.cleanData()
        HMGroupsManager.shared.cleanData()
        
        HMSessionModule.shared.clearSessions()
        
        DDTcpClientManager.instance().delegate = nil
        DDTcpClientManager.instance().disconnect()
    
        self.s_loginState = .offLineInitiative
    }
    
    public  func sendPushtoken(){
//        HMPrint(" Send PushToken :\(self.pushTtoken) ")
        if self.pushTtoken.length > 0 {
            let api =  SendPushTokenAPI.init(pushToken: self.pushTtoken)
            api.request(withParameters: [:], completion: { (obj , error ) in
            })
        }
    }
    
    
    
    
    private func loginStateChangeHandler(){
        
        self.delegate?.loginStateChanged?(state: self.loginState)
//        HMPrint("loginState ChangeHandler  \(self.s_loginState.rawValue)")
        
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
//        HMPrint(" ********** server 嘣 ***********")

        self.receivedServerHeart = true
    }
    
    @objc private func sendHeartBeat(timer:Timer){
//        HMPrint(" ********** send 嘣 ***********")
        HeartbeatAPI.init().request(withParameters: nil) { (object , error ) in }
    }
    @objc private func checkServerHeartBeat(timer:Timer){

        if self.receivedServerHeart {
            self.receivedServerHeart = false
            
            self.p_stopRelogin()
        }else{
            HMPrint("太久没收到服务器端 心跳")
            
            self.p_stopCheckServerHeartBeat()
            self.p_stopHeartBeat()
            
            self.p_startRelogin()
        }
    }
    
    
    @objc private func relogin(timer:Timer){
        reloginTimeN += 1
        
        if reloginTimeN >= self.reloginInterval {
            
            self.relogin(success: { (user ) in
                self.reloginTimer?.invalidate()
                self.reloginTimer = nil
                
                self.reloginTimeN = 0
                self.reloginInterval = 0
                self.powN = 0
                
                self.s_loginState = .online
                
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
                let shouldRelogin:Bool =  !(self.reloginTimer?.isValid ?? false)
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

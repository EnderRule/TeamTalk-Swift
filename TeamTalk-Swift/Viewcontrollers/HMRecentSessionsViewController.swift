//
//  HMRecentSessionsViewController.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/18.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit


class HMRecentSessionsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,HMSessionModuleDelegate,HMLoginManagerDelegate {

    static let shared = HMRecentSessionsViewController()
    
    var holderTitle:String = "消息"
    
    var tableview:UITableView = UITableView.init(frame: .zero, style: .grouped)
    var sessions:[MTTSessionEntity] = []
   
    deinit {
        NotificationCenter.default.removeObserver(self )
        HMSessionModule.shared.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = holderTitle
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.backBarButtonItem = nil
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "sessionCell")
        tableview.register(HMRecentSessionCell.classForCoder(), forCellReuseIdentifier: HMRecentSessionCell.cellIdentifier)

        self.view.addSubview(tableview)
        
        tableview.mas_makeConstraints { ( maker ) in
            maker?.edges.equalTo()(self.view)
        }
        
        
        NotificationCenter.default.addObserver(self , selector: #selector(self.n_receiveLoginFailureNotification(notification:)), name: HMNotification.userLoginFailure.notificationName(), object: nil )
        NotificationCenter.default.addObserver(self , selector: #selector(self.n_receiveLoginSuccessNotification(notification:)), name: HMNotification.userLoginSuccess.notificationName(), object: nil )
        NotificationCenter.default.addObserver(self , selector: #selector(self.n_receiveReLoginSuccessNotification(notification:)), name: HMNotification.userReloginSuccess.notificationName(), object: nil )
        
        HMSessionModule.shared.delegate = self
        HMSessionModule.shared.loadLocalSession { (success ) in
            if success  {
                self.refreshData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false , animated: true)
        
        self.title = self.holderTitle
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //获取最新的会话列表
        dispatch_globle(after: 0.0) {

            HMSessionModule.shared.getRecentSessionFromServer { (count ) in
                self.refreshData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: HMSessionModuleDelegate
    func sessionUpdate(session: MTTSessionEntity, action: HMSessionAction) {
        self.refreshData()
    }

    //MARK: UITableView datasource /delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:HMRecentSessionCell = tableview.dequeueReusableCell(withIdentifier: HMRecentSessionCell.cellIdentifier, for: indexPath) as! HMRecentSessionCell
        
        if indexPath.row < self.sessions.count{
            let session = self.sessions[indexPath.row]
            cell.configWith(object: session)
            
            self.preLoadMessageFor(session: session)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HMRecentSessionCell.cellHeight
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true )
        
        if indexPath.row < self.sessions.count{
            let session = self.sessions[indexPath.row]

            let chattingVC:HMChattingViewController = HMChattingViewController.init(session: session)
            chattingVC.hidesBottomBarWhenPushed = true
            self.push(newVC: chattingVC, animated: true )
        }
    }
    
    //移除会话 session
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.row < self.sessions.count {
                let session:MTTSessionEntity = self.sessions[indexPath.row]
                
                HMSessionModule.shared.removeSessionFromServer(session: session)
                
                self.sessions.remove(at: indexPath.row)
                tableview .deleteRows(at: [indexPath], with: .right)
                
                self.setTabbarBadge(count: Int(HMSessionModule.shared.getAllUnreadMsgCount()))
            }
            
        }
    }
    
    
    
    //MARK:receive notifications
    
    func loginFailure(error: String) {
        
    }
    func loginSuccess(user: MTTUserEntity) {
        
    }
    func loginStateChanged(state: HMLoginState) {
        
    }
    
    func n_receiveLoginFailureNotification(notification:Notification){
        self.title = "未鏈接"
    }
    
    func n_receiveStartLoginNotification(notification:Notification){
        self.title = "連接中..."
    }
    func n_receiveLoginSuccessNotification(notification:Notification){
        self.title = holderTitle
    }
    func n_receiveReLoginSuccessNotification(notification:Notification){
        self.title = holderTitle
        
        dispatch_globle(after: 0.0) {
            HMSessionModule.shared.getRecentSessionFromServer(completion: { (count ) in
                 self.refreshData()
            })
        }
    }
    
    func setTabbarBadge(count:Int){
        if count > 0 {
            if count > 99 {
                self.navigationController?.tabBarItem.badgeValue = "99+"
            }else {
                self.navigationController?.tabBarItem.badgeValue = "\(count)"
            }
        }else {
            self.navigationController?.tabBarItem.badgeValue = nil
        }
        UIApplication.shared.applicationIconBadgeNumber = count
    }
    
    func refreshData(){
        let count:Int = HMSessionModule.shared.getAllUnreadMsgCount()
        self.setTabbarBadge(count: count)
        
        self.sortSessions()
    }
    
    
    private let sortDes1 = [NSSortDescriptor.init(key: "timeInterval", ascending: false)]
    private let sortDes2 = [NSSortDescriptor.init(key: "isFixedTop", ascending: false )]
    func sortSessions(){
        self.sessions.removeAll()
        self.sessions = HMSessionModule.shared.getAllSessions()
        
        if self.sessions.count > 0 {
            self.sessions = (self.sessions as NSArray).sortedArray(using: sortDes1) as! [MTTSessionEntity]
            self.sessions = (self.sessions as NSArray).sortedArray(using: sortDes2) as! [MTTSessionEntity]
        }
        self.tableview .reloadData()
    }
    
    func preLoadMessageFor(session:MTTSessionEntity){
        
        if let message = MTTMessageEntity.getLastestMessage(session: session){
            if message.msgID != session.lastMsgID {
                HMMessageManager.shared.getMsgFromServer(beginMsgID: session.lastMsgID, forSession: session, count: 20, completion: { (messages , error ) in
                })
            }
            
        }else{
            if session.lastMsgID != 0 {
                HMMessageManager.shared.getMsgFromServer(beginMsgID: session.lastMsgID, forSession: session, count: 20, completion: { (messages , error ) in
                })
            }
        }
    }
}

extension MTTMessageEntity {
    class func getLastestMessage(session:MTTSessionEntity)->MTTMessageEntity?{
        
        var message:MTTMessageEntity?
        DispatchQueue.global().sync {
            MTTMessageEntity.dbQuery(whereStr: "sessionId = ? AND stateInt = ?", orderFields: "msgTime", offset: 0, limit: 1, args: [session.sessionID,DDMessageState.SendSuccess.rawValue], completion: { (messages , error ) in
                message = messages.first as? MTTMessageEntity
//                HMPrint("get lastest Message forSession:\(session.sessionID) \(message?.msgID ?? 0) error:\(error?.localizedDescription ?? "")")
            })
        }
        return message
    }
}

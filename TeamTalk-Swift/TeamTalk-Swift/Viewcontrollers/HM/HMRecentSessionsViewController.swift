//
//  HMRecentSessionsViewController.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/18.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class HMRecentSessionsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,DDMessageModuleDelegate,SessionModuelDelegate {

    static let shared = HMRecentSessionsViewController()
    
    var holderTitle:String = "消息"
    
    var tableview:UITableView = UITableView.init(frame: .zero, style: .grouped)
    var sessions:[MTTSessionEntity] = []
   
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self )
        DDMessageModule.shareInstance().remove(self)
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
        
        NotificationCenter.default.addObserver(self , selector: #selector(self.refreshData), name: HMNotification.sessionShieldAndFixed.notificationName(), object: nil )
        NotificationCenter.default.addObserver(self , selector: #selector(self.refreshData), name: HMNotification.reloadRecentContacts.notificationName(), object: nil )
        NotificationCenter.default.addObserver(self , selector: #selector(self.refreshData), name: HMNotification.recentContactsUpdate.notificationName(), object: nil )
        
        DDMessageModule.shareInstance().add(self)
        
        //获取最新的会话列表
        dispatch_globle(after: 0.0) {
            SessionModule.instance().getRecentSession({ (count ) in
                self.refreshData()
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false , animated: true)
        
        self.title = self.holderTitle
        
        self.refreshData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:DDmessagemodule delegate 
    func onReceiveMessage(_ message: MTTMessageEntity!) {
        
        var unreadCount =  SessionModule.instance().getAllUnreadMessageCount()
        
        for session in self.sessions {
            if message.sessionId == session.sessionID {
            
                session.lastMsg = message.msgContent
                session.lastMsgID = message.msgID
                session.timeInterval = TimeInterval(message.msgTime)
                session.lastMessage = message
                
                if let chattingVC:HMChattingViewController = self.navigationController?.topViewController as? HMChattingViewController{
                    if chattingVC.chattingModule.sessionEntity.sessionID != message.sessionId {
                        session.unReadMsgCount += 1
                        unreadCount += 1
                    }
                }else{
                    session.unReadMsgCount += 1
                    unreadCount += 1
                }
                
                MTTDatabaseUtil.instance().updateRecentSession(session, completion: { (error ) in })
                
                self.refreshData()
                
//                tableview.reloadData()
//                self.updateTotalUnread(count: Int(unreadCount))
                
                return
            }
        }
        
        let newsession = MTTSessionEntity.init(sessionID: message.sessionId, sessionName: nil , type: message.sessionType == .sessionTypeGroup ? SessionType_Objc.sessionTypeGroup : SessionType_Objc.sessionTypeSingle)

        newsession.lastMsg = message.msgContent
        newsession.lastMsgID = message.msgID
        newsession.timeInterval = TimeInterval(message.msgTime)
        newsession.lastMessage = message
        newsession.unReadMsgCount = 1
        SessionModule.instance().add(toSessionModel: newsession)
        
        self.refreshData()
        
        MTTDatabaseUtil.instance().updateRecentSession(newsession, completion: { (error ) in
            
        })
        
        unreadCount += 1
        self.updateTotalUnread(count: Int(unreadCount))
        
    }
    
    func updateTotalUnread(count:Int){
        self.setTabbarBadge(count: count)
    }
    
    //MARK: SessionModuelDelegate
    func sessionUpdate(_ session: MTTSessionEntity!, action: SessionAction) {
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
            debugPrint("select session:",session.sessionID)

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
                
                SessionModule.instance().removeSession(byServer: session)
                
                self.sessions.remove(at: indexPath.row)
                tableview .deleteRows(at: [indexPath], with: .right)
                
                self.setTabbarBadge(count: Int(SessionModule.instance().getAllUnreadMessageCount()))
            }
            
        }
    }
    
    
    
    //MARK:receive notifications
    func n_receiveLoginFailureNotification(notification:Notification){
        self.title = "未鏈接"
    }
    
    func n_receiveStartLoginNotification(notification:Notification){
        self.title = holderTitle
    }
    func n_receiveLoginSuccessNotification(notification:Notification){
        self.title = holderTitle
    }
    func n_receiveReLoginSuccessNotification(notification:Notification){
        self.title = holderTitle
        
        dispatch_globle(after: 0.0) {
            SessionModule.instance().getRecentSession({ (count ) in
                self.refreshData()
            })
        }
    }
    
    func setTabbarBadge(count:Int){
        
        debugPrint("HMRecentSession update tabbar badge \(count)")
        
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
        let count:UInt = SessionModule.instance().getAllUnreadMessageCount()
        self.setTabbarBadge(count: Int(count))
        
        self.sortSessions()
    }
    
    
    private let sortDes1 = [NSSortDescriptor.init(key: "timeInterval", ascending: false)]
    private let sortDes2 = [NSSortDescriptor.init(key: "isFixedTop", ascending: false )]
    func sortSessions(){
        self.sessions.removeAll()
        self.sessions = SessionModule.instance().getAllSessions() as? [MTTSessionEntity] ?? []
        
        if self.sessions.count > 0 {
            self.sessions = (self.sessions as NSArray).sortedArray(using: sortDes1) as! [MTTSessionEntity]
            self.sessions = (self.sessions as NSArray).sortedArray(using: sortDes2) as! [MTTSessionEntity]
        }
        self.tableview .reloadData()
    }
    
    func preLoadMessageFor(session:MTTSessionEntity){
        MTTDatabaseUtil.instance().getLastestMessage(forSessionID: session.sessionID) { (message , error ) in
            if message != nil {
                if message!.msgID != session.lastMsgID {
                    
                    DDMessageModule.shareInstance().getMessageFromServer(Int(session.lastMsgID), currentSession: session, count: 20, block: { (array , error ) in
                        if array?.count ?? 0 > 0 {
                            
                            MTTDatabaseUtil.instance().insertMessages(array! as! [Any], success: { 
                                
                            }, failure: { (error ) in
                                
                            })
                        }
                    })
                }
            }else {
                if session.lastMsgID != 0 {
                    DDMessageModule.shareInstance().getMessageFromServer(Int(session.lastMsgID), currentSession: session, count: 20, block: { (array , error ) in
                        if array?.count ?? 0 > 0 {
                            MTTDatabaseUtil.instance().insertMessages(array! as! [Any], success: {
                                
                            }, failure: { (error ) in
                                
                            })
                        }
                    })
                    
                }
            }
        }
        
        
    }
    
}

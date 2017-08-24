//
//  HMRecentSessionsViewController.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/18.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class HMRecentSessionsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    static let shared = HMRecentSessionsViewController()
    
    var holderTitle:String = "消息"
    
    var tableview:UITableView = UITableView.init(frame: .zero, style: .grouped)
    var sessions:[MTTSessionEntity] = []
   
    deinit {
        NotificationCenter.default.removeObserver(self )
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
        if count > 0 {
            if count > 99 {
                self.tabBarItem.badgeValue = "99+"
            }else {
                self.tabBarItem.badgeValue = "\(count)"
            }
        }else {
            self.tabBarItem.badgeValue = nil
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    func refreshData(){
        let count:UInt = SessionModule.instance().getAllUnreadMessageCount()
        self.setTabbarBadge(count: Int(count))
        
        self.sortSessions()
    }
    
    func sortSessions(){
        self.sessions.removeAll()
        self.sessions = SessionModule.instance().getAllSessions() as? [MTTSessionEntity] ?? []
        
        debugPrint("sort sessions :",self.sessions,self.sessions.count)
        
        if self.sessions.count > 0 {
            let sortDes1 = NSSortDescriptor.init(key: "timeInterval", ascending: false)
            let sortDes2 = NSSortDescriptor.init(key: "isFixedTop", ascending: false )
            
            self.sessions = (self.sessions as NSArray).sortedArray(using: [sortDes1]) as! [MTTSessionEntity]
            self.sessions = (self.sessions as NSArray).sortedArray(using: [sortDes2]) as! [MTTSessionEntity]
            
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

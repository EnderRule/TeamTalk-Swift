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
    
    var tableview:UITableView = UITableView.init(frame: .zero, style: .grouped)
    var sessions:[MTTSessionEntity] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = APP_Name
        
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "sessionCell")
        tableview.register(HMRecentSessionCell.classForCoder(), forCellReuseIdentifier: HMRecentSessionCell.cellIdentifier)

        self.view.addSubview(tableview)
        
        tableview.mas_makeConstraints { ( maker ) in
            maker?.edges.equalTo()(self.view)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false , animated: true)
        
        sessions = SessionModule.instance().getAllSessions() as? [MTTSessionEntity] ?? []
        self.tableview.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 

    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:HMRecentSessionCell = tableview.dequeueReusableCell(withIdentifier: HMRecentSessionCell.cellIdentifier, for: indexPath) as! HMRecentSessionCell
        
        if indexPath.row < self.sessions.count{
            let session = self.sessions[indexPath.row]
            cell.configWith(object: session)
        }else{
            cell.imageView?.image = nil
            cell.textLabel?.text = "indexpath row out range "
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
        return 64.0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true )
        
        if indexPath.row < self.sessions.count{
            let session = self.sessions[indexPath.row]
            debugPrint("select session:",session.sessionID)
        }
    }
    
}

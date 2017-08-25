//
//  HMContactsViewController.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/24.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class HMContactsViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate{

    var tableView:UITableView = UITableView.init()
    
    var groups:[MTTGroupEntity] = []
    var users:[MTTUserEntity]   = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "通訊錄"
        
        
        self.setupTableview()
        
        // Do any additional setup after loading the view.
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshContacts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    func setupTableview(){
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: UITableViewCell.cellIdentifier)
        tableView.register(HMContactsCell.classForCoder(), forCellReuseIdentifier: HMContactsCell.cellIdentifier)
        
        self.view.addSubview(self.tableView)
        
        tableView.mas_makeConstraints { (maker ) in
            maker?.edges.mas_equalTo()(self.view)
        }
        
        tableView.addHeader { 
            self.refreshContacts()
        }
        
    }
    
    func refreshContacts(){
        self.users.removeAll()
        for obj in  DDUserModule.shareInstance().getAllMaintanceUser(){
            if let user = obj as? MTTUserEntity{
                self.users.append(user)
            }
        }
        
        self.groups.removeAll()
        for obj in DDGroupModule.instance().getAllGroups() {
            if let group = obj as? MTTGroupEntity {
                self.groups.append(group )
            }
        }
        self.tableView.headerEndRefreshing()
        self.tableView.reloadData()
    }
    
    
    //MARK: - tableview delegate /datasource 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HMAvatarGap * 2 + 40
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.groups.count
        }else {
            return self.users.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:HMContactsCell = tableView.dequeueReusableCell(withIdentifier: HMContactsCell.cellIdentifier, for: indexPath) as! HMContactsCell
        
        if indexPath.section == 0 {
            if indexPath.row < self.groups.count {
                let group = self.groups[indexPath.row]
                cell.configWith(object: group)
            }
        }else  {
            if indexPath.row < self.users.count {
                let user = self.users[indexPath.row]
                cell.configWith(object: user)
            }
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row < self.groups.count {
                let group = self.groups[indexPath.row]
                print("selected group :",group.objID,group.name)
            }
        }else  {
            if indexPath.row < self.users.count {
                let user = self.users[indexPath.row]
                print("selected user :",user.userId,user.name)

                let session = MTTSessionEntity.init(user: user)
                let chatvc = HMChattingViewController.init(session: session)
                chatvc.hidesBottomBarWhenPushed = true
                self.push(newVC: chatvc, animated: true )
                
            }
            
        }
    }
    

}

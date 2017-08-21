//
//  HMChattingViewController.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class HMChattingViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    
    private var chattingModule:ChattingModule!

    private var tableView:UITableView = UITableView.init()
    
    private var showingMessages:[Any] = []
    
    public convenience init(session:MTTSessionEntity){
        self.init()
        
        self.chattingModule  = ChattingModule.init()
        chattingModule.sessionEntity = session
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = colorMainBg
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView.init()
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = UIColor.green
        
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: UITableViewCell.cellIdentifier)
        tableView.register(HMChatTextCell.classForCoder(), forCellReuseIdentifier: HMChatTextCell.cellIdentifier)
        tableView.register(HMChatImageCell.classForCoder(), forCellReuseIdentifier: HMChatImageCell.cellIdentifier)
        tableView.register(HMChatVoiceCell.classForCoder(), forCellReuseIdentifier: HMChatVoiceCell.cellIdentifier)
        tableView.register(HMChatVideoCell.classForCoder(), forCellReuseIdentifier: HMChatVideoCell.cellIdentifier)
        tableView.register(HMChatPromptCell.classForCoder(), forCellReuseIdentifier: HMChatPromptCell.cellIdentifier)
        tableView.register(HMChatEmotionCell.classForCoder(), forCellReuseIdentifier: HMChatEmotionCell.cellIdentifier)
        
        self.view.addSubview(tableView)
        
        tableView.mas_makeConstraints { (maker ) in
            maker?.edges.equalTo()(self.view)
        }
        
        chattingModule.getNewMsg { (count , error) in
            print("get newmsg :\(count)",error?.localizedDescription ?? "nil error")
            
            if count > 0{
                self.refreshData()
            }
        }
        
        
        chattingModule.loadMoreHistoryCompletion { (count , error ) in
            print("load more history  :\(count)",error?.localizedDescription ?? "nil error")

            if count > 0{
                self.refreshData()
            }
        }
    }

    func refreshData(){

        self.showingMessages = chattingModule.showingMessages as! [Any]

        self.tableView.reloadData()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false , animated: true )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.refreshData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
 
    }
    
 
    //MARK: uitableView datasource/delegate 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count  = self.showingMessages.count
        print("numberOfRowsInSection showingmessages ",self.showingMessages)
        return count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < self.showingMessages.count {
             let obj = self.showingMessages[indexPath.row]
            if let message = obj as? MTTMessageEntity {
            
                return message.cellHeight()
            }else if obj is DDPromptEntity {
                return 30.0 // prompt.cellHeight()
            }
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < self.showingMessages.count {
            let obj = self.showingMessages[indexPath.row]
            if let message = obj as? MTTMessageEntity {
                
                if message.msgContentType == .Text {
                    
                }
                
            }else if let prompt = obj as? DDPromptEntity {
                
                let promptCell:HMChatPromptCell = tableView.dequeueReusableCell(withIdentifier: HMChatPromptCell.cellIdentifier, for: indexPath) as! HMChatPromptCell
                promptCell.configWith(object: prompt)
                
                return promptCell
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.cellIdentifier, for: indexPath)
        return cell;
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false )
        
        chattingModule.addPrompt("select row \(indexPath.row)")
        
        self.refreshData()
    }
    
}

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
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: UITableViewCell.cellIdentifier)
        tableView.register(HMChatTextCell.classForCoder(), forCellReuseIdentifier: HMChatTextCell.cellIdentifier)
        tableView.register(HMChatImageCell.classForCoder(), forCellReuseIdentifier: HMChatImageCell.cellIdentifier)
        tableView.register(HMChatVoiceCell.classForCoder(), forCellReuseIdentifier: HMChatVoiceCell.cellIdentifier)
        tableView.register(HMChatVideoCell.classForCoder(), forCellReuseIdentifier: HMChatVideoCell.cellIdentifier)
        tableView.register(HMChatPromptCell.classForCoder(), forCellReuseIdentifier: HMChatPromptCell.cellIdentifier)
        tableView.register(HMChatEmotionCell.classForCoder(), forCellReuseIdentifier: HMChatEmotionCell.cellIdentifier)
        
        self.view.addSubview(tableView)
        
        
    }

    func refreshData(){
        self.chattingModule.loadMoreHistoryCompletion { (count , error ) in
            self.tableView.reloadData()
        }
        
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
        return self.chattingModule.showingMessages.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < self.chattingModule.showingMessages.count {
             let obj = self.chattingModule.showingMessages.object(at: indexPath.row)
            if let message = obj as? MTTMessageEntity {
            
                return message.cellHeight()
            }else if let prompt = obj as? MTTPromtEntity {
                return prompt.cellHeight()
            }
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.cellIdentifier, for: indexPath)
        if indexPath.row < self.chattingModule.showingMessages.count {
            let obj = self.chattingModule.showingMessages.object(at: indexPath.row)
            if let message = obj as? MTTMessageEntity {
                
                if message.msgContentType == .Text {
                    
                }
                
            }else if let prompt = obj as? MTTPromtEntity {
                
                let promptCell:HMChatPromptCell = tableView.dequeueReusableCell(withIdentifier: HMChatPromptCell.cellIdentifier, for: indexPath) as! HMChatPromptCell
                promptCell.configWith(object: prompt)
                
                return promptCell
            }
        }
        return cell;
    }
    
}

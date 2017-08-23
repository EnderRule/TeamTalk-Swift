//
//  HMChattingViewController.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

let ChatInputView_MinHeight:CGFloat = 44.0


class HMChattingViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,
NIMInputDelegate,NIMInputViewConfig,NIMInputActionDelegate,TZImagePickerControllerDelegate {

    
    private var chattingModule:ChattingModule!

    private var chatInputView:NIMInputView!
    private var tableView:UITableView = UITableView.init()
    
    private var showingMessages:[Any] = []
    
    public convenience init(session:MTTSessionEntity){
        self.init()
        
        self.chattingModule  = ChattingModule.init()
        chattingModule.sessionEntity = session
        
        chattingModule.addObserver(self , forKeyPath: "showingMessages", options: .new, context: nil )
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self )
        chattingModule.removeObserver(self , forKeyPath: "showingMessages")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = colorMainBg
        
        self.setupChatInputView()
        
        self.setupChatMessagesTableview()
        
        chattingModule.getNewMsg { (count , error) in
            print("get newmsg :\(count)",error?.localizedDescription ?? "nil error")
            
            if count > 0{
                self.refreshMessagesData()
            }
        }
        
        
        chattingModule.loadMoreHistoryCompletion { (count , error ) in
            print("load more history  :\(count)",error?.localizedDescription ?? "nil error")

            if count > 0{
                self.refreshMessagesData()
            }
        }
    }


    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false , animated: true )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        self.refreshMessagesData()
        self.navigationItem.title = self.chattingModule.sessionEntity.name
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupChatInputView(){
        let inputRect = CGRect.init(x: 0, y: SCREEN_HEIGHT() - ChatInputView_MinHeight, width: SCREEN_WIDTH(), height: ChatInputView_MinHeight)
        
        chatInputView = NIMInputView.init(frame: inputRect)
        chatInputView.setInputActionDelegate(self)
        chatInputView.setInputDelegate(self)
        chatInputView.setInputConfig(self)
        
        chatInputView.backgroundColor = colorMainBg
        self.view.addSubview(chatInputView)
    }
    
    func setupChatMessagesTableview(){
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
            maker?.top.mas_equalTo()(self.view.mas_top)?.offset()(64)
            maker?.left.mas_equalTo()(self.view.mas_left)
            maker?.right.mas_equalTo()(self.view.mas_right)
            maker?.bottom.mas_equalTo()(self.chatInputView.mas_top)
        }
        
    }
    
    
    func refreshMessagesData(){
        
        self.showingMessages = chattingModule.showingMessages as! [Any]
        
        self.tableView.reloadData()
        self.tableView.checkScrollToBottom()
    }
 
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (object as? ChattingModule) == self.chattingModule  && keyPath == "showingMessages"{
            self.refreshMessagesData()
        }
    }
    
    //MARK: uitableView datasource/delegate 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count  = self.showingMessages.count
        print("numberOfRowsInSection showingmessages ",self.showingMessages.count)
        return count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < self.showingMessages.count {
             let obj = self.showingMessages[indexPath.row]
            if let message = obj as? MTTMessageEntity {
                let messageCell : HMChatBaseCell = HMChatBaseCell.init(style: .default, reuseIdentifier: HMChatBaseCell.cellIdentifier )
                return messageCell.cellHeightFor(message: message)
            }else if obj is DDPromptEntity {
                return 30.0
            }
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < self.showingMessages.count {
            let obj = self.showingMessages[indexPath.row]
            if let message = obj as? MTTMessageEntity {
                
                if message.msgContentType == .Image {
                    let cell:HMChatImageCell = tableView.dequeueReusableCell(withIdentifier: HMChatImageCell.cellIdentifier, for: indexPath) as! HMChatImageCell
                    
                    cell.setContent(message: message)
                    return cell
                    
                }else if message.msgContentType == .Emotion {
                    let cell:HMChatEmotionCell = tableView.dequeueReusableCell(withIdentifier: HMChatEmotionCell.cellIdentifier, for: indexPath) as! HMChatEmotionCell
                    
                    cell.setContent(message: message)
                    return cell
                }
                let messageCell : HMChatTextCell = tableView.dequeueReusableCell(withIdentifier: HMChatTextCell.cellIdentifier, for: indexPath) as! HMChatTextCell
                
                messageCell.setContent(message: message)
                return messageCell
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
    }
    
    
    func sendMessage(msgEntity:MTTMessageEntity){
        
        DDMessageSendManager.instance().sendMessage(msgEntity, isGroup: self.chattingModule.sessionEntity.isGroupSession, session: self.chattingModule.sessionEntity, completion: {[weak self] (messageentity, error ) in
            
            if messageentity != nil {
                msgEntity.state = messageentity!.state
            }else {
                msgEntity.state = .SendFailure
            }
            dispatch(after: 0, task: { 
                self?.tableView.reloadData()
            })
        }) {[weak self] (error ) in
            msgEntity.state = .SendFailure
            
            self?.tableView.reloadData()
        }
        
    }
    
    //MARK: pick/shoot photos
    func onTapMediaItemPick(){
        print("相册选照片")
        
        let imagePickvc:TZImagePickerController = TZImagePickerController.init(maxImagesCount: 1, delegate: self)

        imagePickvc.allowPreview = true
        imagePickvc.allowTakePicture = true
        imagePickvc.allowPickingVideo = false
        imagePickvc.allowPickingGif = false
        imagePickvc.allowCrop = true
        
        self.present(imagePickvc, animated: true , completion: nil )
        
//        self.push(newVC: imagePickvc, animated: true )
        
    }
    func onTapMediaItemShoot(){
        print("相机拍照片")
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool, infos: [[AnyHashable : Any]]!) {
        guard  photos.count >  0 else { return }
        let image = photos.first!
        
        let imagePath = ZQFileManager.shared.tempPathFor(image: image)
        guard imagePath.length > 0 else {
            return
        }
        print("ready to upload messageImage:\(imagePath)")
        
        let messageContentDic = NSDictionary.init(dictionary: [MTTMessageEntity.DD_IMAGE_LOCAL_KEY:imagePath])
        let messageContentStr = messageContentDic.jsonString() ?? ""
        
        let messageEntity = MTTMessageEntity.init(content: messageContentStr, module: self.chattingModule, msgContentType: DDMessageContentType.Image)
    
        MTTDatabaseUtil.instance().insertMessages([messageEntity], success: {
            
        }) { (error ) in
            
        }
        
        //先上传图片、再发送含有图片URL 的消息。
        DDSendPhotoMessageAPI.sharedPhotoCache().uploadImage(imagePath, success: {[weak self ] (imageURL ) in
            if imageURL != nil {
                messageEntity.state = .Sending
                
                var tempContentDic = NSDictionary.initWithJsonString(messageEntity.msgContent) ?? [:]
                tempContentDic.updateValue(imageURL!, forKey: MTTMessageEntity.DD_IMAGE_URL_KEY)
                let tempMsgContent = (tempContentDic as NSDictionary).jsonString() ?? ""
                messageEntity.msgContent = tempMsgContent
                
                
                self?.sendMessage(msgEntity: messageEntity)
                messageEntity.updateToDB(compeletion: nil)
            }
        }) {[weak self ] (error ) in
            messageEntity.state = .SendFailure
            messageEntity.updateToDB(compeletion: { (success ) in
                if success {
                    dispatch(after: 0, task: { 
                         self?.tableView.reloadData()
                    })
                }
            })
        }
        
        
    }
    
    
    //MARK: NIMInputView related delegates
    func disableCharlet() -> Bool {
        return false
    }
    func disableInputView() -> Bool {
        return false
    }
    
    func mediaItems() -> [NIMMediaItem]! {
        
        return NIMMediaItem.defaultItems()
    }
    
    func onTap(_ item: NIMMediaItem!){
        print("tap on meida item:",item.title,NSStringFromSelector(item.selector))
        if self.responds(to: item.selector){
            self.perform(item.selector)
        }
    }
    
    func onTextChanged(_ sender: Any!) {
        print("input view text change \(sender) ")
    }
    
    func onSendText(_ text: String!, atUsers: [Any]!) {
        print("input view : sendtext:\(text)")
        guard text.length > 0 else {
            return
        }
        let messageEntity = MTTMessageEntity.init(content: text, module: self.chattingModule, msgContentType: DDMessageContentType.Text)
        
        MTTDatabaseUtil.instance().insertMessages([messageEntity], success: {
        }) { (error ) in
        }
        self.sendMessage(msgEntity: messageEntity)
    }
    
    func onSelectChartlet(_ chartletId: String!, catalog catalogId: String!) {
        print("input ivew select chartlet : \(chartletId) \(catalogId)")
        
        if catalogId == "mgj" && chartletId.length > 0{

            var msgcontent:String = ""
            for keyValue in MTTMessageEntity.mgjEmotionDic.enumerated(){
               if keyValue.element.value == chartletId  {
                    msgcontent = keyValue.element.key
                    break
                }
            }
            debugPrint("select \(msgcontent)")
            
            if msgcontent.length > 0 {
                let messageEntity = MTTMessageEntity.init(content: msgcontent, module: self.chattingModule, msgContentType: DDMessageContentType.Emotion)

                MTTDatabaseUtil.instance().insertMessages([messageEntity], success: {
                }) { (error ) in
                }
                self.sendMessage(msgEntity: messageEntity)
            }
        }else{
            let messageEntity = MTTMessageEntity.init(content: "[\(catalogId!)/\(chartletId!)]", module: self.chattingModule, msgContentType: DDMessageContentType.Emotion)
            
            MTTDatabaseUtil.instance().insertMessages([messageEntity], success: {
            }) { (error ) in
            }
            self.sendMessage(msgEntity: messageEntity)
            
        }
        
    }
    
    func onAtStart() -> Bool {
        
        print("input view atStart")
        
        self.chatInputView.didFinishedSelect([["uid":"2213","name":"哈哈哈😆"],["uid":"22133","name":"哈哈哈222😆"],])
        
        return false
    }
    
    func onCancelRecording() {
        print("input view onCancelRecording")
    }
    func onStartRecording() {
        print("input view onStartRecording")
    }
    func onStopRecording() {
        print("input view onStopRecording")
    }
}
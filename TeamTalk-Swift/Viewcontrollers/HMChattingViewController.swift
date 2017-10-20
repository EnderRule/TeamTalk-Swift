//
//  HMChattingViewController.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

import AudioToolbox
import SVProgressHUD

let ChatInputView_MinHeight:CGFloat = 44.0


class HMChattingViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,
NIMInputDelegate,NIMInputViewConfig,NIMInputActionDelegate,HMChatCellActionDelegate,RecordingDelegate,PlayingDelegate {

    private var currentVoicePlayingCell:HMChatVoiceCell?

    var chattingModule:HMChattingModule!

    private var chatInputView:NIMInputView!
    private var tableView:UITableView = UITableView.init()
    
    private var showingMessages:[Any] = []
    private var noMoreRecords:Bool = false
    
    public convenience init(session:MTTSessionEntity){
        self.init()
        
        self.chattingModule  = HMChattingModule.init(session: session)
        chattingModule.showingMessageChangedHandledBlock = {
            self.refreshMessagesData(scrollToBottom: false)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self )
        chattingModule.showingMessageChangedHandledBlock = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = colorMainBg
        
        self.noMoreRecords = false
        
        self.setupChatMessagesTableview()

        self.setupChatInputView()
        
        tableView.mas_makeConstraints { (maker ) in
            maker?.top.mas_equalTo()(self.view.mas_top)
            maker?.left.mas_equalTo()(self.view.mas_left)
            maker?.right.mas_equalTo()(self.view.mas_right)
            maker?.bottom.mas_equalTo()(self.chatInputView.mas_top)
        }
        
        
        NotificationCenter.default.addObserver(self , selector: #selector(self.onReceiveMessage(notification:) ), name: HMNotification.receiveMessage.notificationName(), object: nil )
    }
 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationItem.title = self.chattingModule.sessionEntity.name
        self.navigationController?.setNavigationBarHidden(false , animated: true )
        
        self.noMoreRecords = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        if chattingModule.showingMessages.count == 0 {
            chattingModule.loadMoreHistory(completion: { (count , error ) in
                
                if count > 0{
                    self.refreshMessagesData(scrollToBottom: true )
                }
            })
        }
        
        self.refreshMessagesData(scrollToBottom: true )

        //清空未读 = 0
        self.chattingModule.sessionEntity.unReadMsgCount = 0
        self.chattingModule.sessionEntity.dbUpdate(completion: nil)
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
        
//        self.recordIndicatorView.frame = .init(x: 00, y: 0, width: 160, height: 160)
//        self.recordIndicatorView.recordTime = 0
        
    }
    
    func setupChatMessagesTableview(){
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView.init()
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.keyboardDismissMode = .onDrag
        
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: UITableViewCell.cellIdentifier)
        tableView.register(HMChatTextCell.classForCoder(), forCellReuseIdentifier: HMChatTextCell.cellIdentifier)
        tableView.register(HMChatImageCell.classForCoder(), forCellReuseIdentifier: HMChatImageCell.cellIdentifier)
        tableView.register(HMChatVoiceCell.classForCoder(), forCellReuseIdentifier: HMChatVoiceCell.cellIdentifier)
        tableView.register(HMChatVideoCell.classForCoder(), forCellReuseIdentifier: HMChatVideoCell.cellIdentifier)
        tableView.register(HMChatPromptCell.classForCoder(), forCellReuseIdentifier: HMChatPromptCell.cellIdentifier)
        tableView.register(HMChatEmotionCell.classForCoder(), forCellReuseIdentifier: HMChatEmotionCell.cellIdentifier)
        
        self.view.addSubview(tableView)
        

        tableView.mj_addHeader(config: { (header ) in
            header.setTitle("下拉載入更多", for: .idle)
            header.setTitle("鬆開后載入", for: .pulling)
            header.setTitle("正在載入...", for: .refreshing)
            header.setTitle("没有更多了", for: .noMoreData)
         }) {
            self.loadMoreHistoryRecords()
        }
    }
    
    
    func loadMoreHistoryRecords(){
        let contentSizeHeightOld:CGFloat = self.tableView.contentSize.height
        let contentOffsetYOld:CGFloat = self.tableView.contentOffset.y
        
        self.chattingModule.loadMoreHistory { [weak self ] (count , error ) in
            if error != nil  && error!.localizedDescription.length > 0 {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
                
                self?.tableView.mj_headerEndRefreshing()
                return
            }
            
            if count > 0 {
                self?.refreshMessagesData(scrollToBottom: false)
                self?.tableView.mj_headerEndRefreshing()
                
                let contentSizeHeightNew:CGFloat = self?.tableView.contentSize.height ?? 0
                let contentOffsetYNew:CGFloat = contentSizeHeightNew - contentSizeHeightOld + contentOffsetYOld
                self?.tableView.setContentOffset(CGPoint.init(x: 0, y: contentOffsetYNew), animated: false )
            }else {
                HMPrint("load more history messages for session \(self?.chattingModule.sessionEntity.sessionID ?? "") ,but no more")

                self?.noMoreRecords = true
                self?.tableView.mj_headerEndRefreshing()
            }
        }
    }
    
    
    func refreshMessagesData(scrollToBottom:Bool){
        
        
        self.showingMessages = chattingModule.showingMessages
        
        self.tableView.reloadData()
        if scrollToBottom{
            self.tableView.checkScrollToBottom()
        }
    }
 
    
    
    //MARK: uitableView datasource/delegate 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count  = self.showingMessages.count
        return count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < self.showingMessages.count {
             let obj = self.showingMessages[indexPath.row]
            if let message = obj as? MTTMessageEntity {
                let messageCell : HMChatBaseCell = HMChatBaseCell.init(style: .default, reuseIdentifier: HMChatBaseCell.cellIdentifier )
                return messageCell.cellHeightFor(message: message)
            }else if obj is HMPromptEntity {
                return 30.0
            }
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < self.showingMessages.count {
            let obj = self.showingMessages[indexPath.row]
            if let message = obj as? MTTMessageEntity {
                
                
                if !message.isGroupMessage && message.senderId != HMLoginManager.shared.currentUser.userId {
                    
                    
                    if MTTMsgReadState.stateFor(message:message) != .Readed{
                     
                        HMMessageManager.shared.sendReadACK(message: message)
                     
                        MTTMsgReadState.save(message:message, state: .Readed)
                        
                        message.state = .Readed
                        message.dbSave(completion: { (success ) in
                            HMPrint(" 发送已读回执：db save \(success) \(message.msgID) \(message.sessionId) \(message.msgContent)")
                        })
                    }
                }
                
                if message.msgContentType == .Image {
                    let cell:HMChatImageCell = tableView.dequeueReusableCell(withIdentifier: HMChatImageCell.cellIdentifier, for: indexPath) as! HMChatImageCell
                    
                    cell.setContent(message: message)
                    cell.delegate = self
                    return cell
                    
                }else if message.msgContentType == .Emotion {
                    let cell:HMChatEmotionCell = tableView.dequeueReusableCell(withIdentifier: HMChatEmotionCell.cellIdentifier, for: indexPath) as! HMChatEmotionCell
                    cell.delegate = self

                    cell.setContent(message: message)
                    return cell
                } else if message.msgContentType == .Voice {
                    let cell:HMChatVoiceCell = tableView.dequeueReusableCell(withIdentifier: HMChatVoiceCell.cellIdentifier, for: indexPath) as! HMChatVoiceCell
                    cell.delegate = self

                    cell.setContent(message: message)
                    return cell
                }
                let cell : HMChatTextCell = tableView.dequeueReusableCell(withIdentifier: HMChatTextCell.cellIdentifier, for: indexPath) as! HMChatTextCell
                cell.delegate = self

                cell.setContent(message: message)
                return cell
            }else if let prompt = obj as? HMPromptEntity {
                
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.chatInputView.resignFirstResponder()
    }
    
    
    func sendMessage(msgEntity:MTTMessageEntity){
        self.tableView.checkScrollToBottom()
        
        HMMessageManager.shared.sendNormal(message: msgEntity, session: self.chattingModule.sessionEntity) {[weak self] (message , error ) in
            if error != nil {
                HMPrint("HMChatting send message \(message.msgContent) \n error: \(error!.localizedDescription)")
            }
            
            dispatch(after: 0.0, task: { 
                self?.tableView.reloadData()
            })
        }
    }
    
    //MARK: pick/shoot photos
    func onTapMediaItemPick(){
        
        ZQMediaFetch.shared.fetchPhoto(maxCount: 1, configPicker: { (imagePickvc ) in
            imagePickvc.allowPreview = true
            imagePickvc.allowTakePicture = true
            imagePickvc.allowPickingVideo = false
            imagePickvc.allowPickingGif = false
            imagePickvc.allowCrop = true
        }, finish: { (photos , assets, isoriginal, infos) in
            guard  photos.count >  0 else { return }
            let image = photos.first!
            
            let imagePath = ZQFileManager.shared.tempPathFor(image: image)
            guard imagePath.length > 0 else {
                return
            }
            self.sendLocalImage(imagePath: imagePath)
        }) {
            //cancel
        }
        
    }
    func onTapMediaItemShoot(){
        HMPrint("相机拍照片")
    }
    
    private func sendLocalImage(imagePath:String){
        
        
        
        HMMessageManager.shared.sendImage(imagePath: imagePath, chattingModule: self.chattingModule, willSend: { (message ) in
                self.tableView.reloadData()
        }, progress: { (message , progress ) in
            HMPrint("send image to \(self.chattingModule.sessionEntity.sessionID) progress:\(progress)")
            
        }) { (message , error ) in
            if (error != nil ){
                HMPrint("send image error:\(error!.localizedDescription)")
            }
            self.tableView.reloadData()
        }
        
        
//        HMPrint("ready to upload messageImage:\(imagePath)")
//        
//        var scale:CGFloat = 1.618
//        if let image:UIImage = UIImage.init(contentsOfFile: imagePath){
//            scale = image.size.width/image.size.height
//         }
//
//        let newMessage:MTTMessageEntity = MTTMessageEntity.initWith(content: "[圖片]", module: self.chattingModule, msgContentType: DDMessageContentType.Image)
//        newMessage.imageLocalPath = imagePath
//        newMessage.imageScale = scale
//        
//        newMessage.dbSave(completion: nil)
//        
//        //先上传图片、再发送含有图片URL 的消息。
//        SendPhotoMessageAPI.shared.uploadPhoto(imagePath: imagePath, to: self.chattingModule.sessionEntity, progress: { (progress ) in
//            HMPrint("upload progress \(progress.completedUnitCount)/\(progress.totalUnitCount)  \(CGFloat(progress.completedUnitCount)/CGFloat(progress.totalUnitCount))")
//        }, success: {[weak self] (imageURL ) in
//            HMPrint("upload success url: \(imageURL)")
//            if imageURL.length > 0 {
//                newMessage.state = .Sending
//                
//                newMessage.imageUrl = imageURL
//                
//                self?.sendMessage(msgEntity: newMessage)
//                newMessage.updateToDB(compeletion: nil)
//            }
//        }) {[weak self ] (errorString ) in
//            
//            HMPrint("upload error :\(errorString)")
//            
//            newMessage.state = .SendFailure
//            newMessage.updateToDB(compeletion: { (success ) in
//                if success {
//                    dispatch(after: 0, task: {
//                        self?.tableView.reloadData()
//                    })
//                }
//            })
//        }
    
        
    }
    
    
    //MARK: 消息管理代理
    @objc private func onReceiveMessage(notification:NSNotification) {
        guard let message:MTTMessageEntity = notification.object as? MTTMessageEntity else {
            return
        }
        
        if message.sessionId == self.chattingModule.sessionEntity.sessionID {
            self.chattingModule.addShow(message: message)
            self.chattingModule.updateSession(updateTime: TimeInterval(message.msgTime))
            self.chattingModule.sessionEntity.lastMsg = message.msgContent

            self.refreshMessagesData(scrollToBottom: true )
         
        }
    }
    
    
    //MARK: NIMInputView related delegates
    func disableAtUser() -> Bool {
        return true
    }
    
    func onInputViewActive(_ active: Bool) {
        if active{
            self.tableView.checkScrollToBottom()
        }
    }
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
        if self.responds(to: item.selector){
            self.perform(item.selector)
        }
    }
    
    func onTextChanged(_ sender: Any!) {

    }
    
    func onSendText(_ text: String!, atUsers: [Any]!) {
        guard text.length > 0 else {
            return
        }
        let messageEntity = MTTMessageEntity.initWith(content: text, module: self.chattingModule, msgContentType: .Text)
        messageEntity.dbSave(completion: nil)

        
        self.sendMessage(msgEntity: messageEntity)
    }
    
    func onSelectChartlet(_ chartletId: String!, catalog categoryId: String!) {
        
        var msgcontent:String = ""
        if categoryId == "mgj" && chartletId.length > 0{
            for keyValue in MTTEmotionManager.mgjEmotionDic.enumerated(){
               if keyValue.element.value == chartletId  {
                    msgcontent = keyValue.element.key
                    break
                }
            }
            if msgcontent.length <= 0 {
                msgcontent = "[貼圖]"
            }
        }else{
            msgcontent = "[貼圖]"
        }
        HMPrint("select charlet \(msgcontent)   \(categoryId!)   \(chartletId!)")
        
        let messageEntity = MTTMessageEntity.initWith(content: msgcontent, module: self.chattingModule, msgContentType: .Emotion)

        messageEntity.emojiText = msgcontent
        messageEntity.emojiCategory = categoryId
        messageEntity.emojiName = chartletId
        messageEntity.dbSave(completion: nil)
        
        self.sendMessage(msgEntity: messageEntity)
    }
    
    func onAtStart() -> Bool {
        self.chatInputView.didFinishedSelect([["uid":"2213","name":"哈哈哈😆"],["uid":"22133","name":"哈哈哈222😆"],])
        
        return false
    }
    
    func onCancelRecording() {
        RecorderManager.shared().cancelRecording()
    }
    func onStartRecording() {
        RecorderManager.shared().delegate = self
        RecorderManager.shared().startRecording()

    }
    func onStopRecording() {
        RecorderManager.shared().stopRecording()
    }
    
    
    //MARK:voice recording delegate  //錄音代理中更新UI 需切換到主線程中來
    func recordingFinished(withFileName filePath: String!, time interval: TimeInterval) {
        HMPrint("chatting recording Finished  \(interval)"  )
       dispatch(after: 0) {
            guard  interval > 2 else {
                SVProgressHUD.showError(withStatus: "錄音時間太短啦")
                return
            }
            
            let voicePath:String = filePath
            let newmessage = MTTMessageEntity.initWith(content: voicePath, module: self.chattingModule, msgContentType: .Voice)
            newmessage.msgType = .msgTypeSingleAudio
            newmessage.voiceLocalPath = voicePath
            newmessage.voiceLength = Int(interval)
        
            newmessage.dbSave(completion: nil)
        
            self.sendMessage(msgEntity: newmessage)
        }
    }
    
    func recordingFailed(_ failureInfoString: String!) {
        dispatch(after: 0) { 
            SVProgressHUD.showError(withStatus: "錄音失敗：\(failureInfoString)")
        }
    }
    func recordingStopped() {
        dispatch(after: 0) { 
            self.chatInputView.updateAudioRecordTime(0)
        }
    }
    func recordAudioProgress(_ currentTime: TimeInterval) {
        HMPrint("chatting  update RecordTime \(currentTime)")

        dispatch(after: 0) { 
            self.chatInputView.updateAudioRecordTime(currentTime)
        }
    }
    
    //MARK: voice playing Delegate
    func playingStoped() {
        dispatch(after: 0.0) {
            self.currentVoicePlayingCell?.updatePlayState(isPlaying: false)
            self.currentVoicePlayingCell = nil
        }
    }
    
    //MARK: HMChat cell action delegate
    func HMChatCellAction(type: HMChatCellActionType, message: MTTMessageEntity?, sourceView: UIView?) {
        
        HMPrint("HMChatCellAction \(type),message \(message?.msgContent ?? "nil msgcontent")")
        
        
        
        if type == .sendAgain && message != nil{
            
            if message!.isImageMessage{
                let imageurl = message!.imageUrl
                let imageLocal = message!.imageLocalPath.safeLocalPath()

                if imageurl.length <= 0 && FileManager.default.fileExists(atPath: imageLocal){
                    
                    message?.dbDelete(completion: { (success ) in
                        dispatch(after: 0, task: {
                            self.chattingModule.deleteShow(message: message!)
                            
                            self.showingMessages = self.chattingModule.showingMessages
                            self.tableView.reloadData()
                            self.tableView.checkScrollToBottom()
                        })
                    })
                    self.sendLocalImage(imagePath: imageLocal)
                }else if imageurl.length > 0 {
                    message!.msgTime = UInt32(Date().timeIntervalSince1970)
                    message?.state = .Sending
                    
                    message?.updateToDB(compeletion: nil )
                    self.sendMessage(msgEntity: message!)
                } else{
                    SVProgressHUD.showError(withStatus: "圖片不存在")
                }
            }else{
                message!.msgTime = UInt32(Date().timeIntervalSince1970)
                message?.state = .Sending
                
                message?.updateToDB(compeletion: nil )
                self.sendMessage(msgEntity: message!)
            }
            
        }else if  type == .voicePlayOrStop {
            if PlayerManager.shared().isPlaying(){
                PlayerManager.shared().stopPlaying()
                self.currentVoicePlayingCell?.updatePlayState(isPlaying: false)
            }else{
                let localPath = message?.msgContent.safeLocalPath() ?? ""
                if FileManager.default.fileExists(atPath: localPath){
                    PlayerManager.shared().stopPlaying()  //必須 停止之前的播放  ，否則無法更新上個播放對應的cell的UI
                    
                    self.currentVoicePlayingCell  = sourceView as? HMChatVoiceCell
                    self.currentVoicePlayingCell?.updatePlayState(isPlaying: true)

                    PlayerManager.shared().playAudio(withFileName: localPath, playerType: .DDSpeaker, delegate: self)
                    
                }else{
                    SVProgressHUD.showError(withStatus: "音頻文件不存在")
                }
            }
        }
        
    }
    
}

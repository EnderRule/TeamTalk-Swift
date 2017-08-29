//
//  HMChattingViewController.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

import AudioToolbox

let ChatInputView_MinHeight:CGFloat = 44.0


class HMChattingViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,
NIMInputDelegate,NIMInputViewConfig,NIMInputActionDelegate,TZImagePickerControllerDelegate,DDMessageModuleDelegate,HMChatCellActionDelegate,AVAudioPlayerDelegate {

    private var audioPlayer:AVAudioPlayer?
    private var audioRecorder:AVAudioRecorder?
    private var recordVoicePath:String = ""
    private var recordTimeInterval:TimeInterval = 0
//    private var recordIndicatorView:NIMInputAudioRecordIndicatorView = NIMInputAudioRecordIndicatorView.init()
    private var chattingModule:ChattingModule!

    private var chatInputView:NIMInputView!
    private var tableView:UITableView = UITableView.init()
    
    private var showingMessages:[Any] = []
    private var noMoreRecords:Bool = false
    
    public convenience init(session:MTTSessionEntity){
        self.init()
        
        self.chattingModule  = ChattingModule.init()
        chattingModule.sessionEntity = session
        
        chattingModule.addObserver(self , forKeyPath: "showingMessages", options: .new, context: nil )
    
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self )
        chattingModule.removeObserver(self , forKeyPath: "showingMessages")

        DDMessageModule.shareInstance().remove(self)
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
        
        chattingModule.loadMoreHistoryCompletion { (count , error ) in
            print("load more history  :\(count)",error?.localizedDescription ?? "nil error")

            if count > 0{
                self.refreshMessagesData(scrollToBottom: true )
            }
        }
    }
 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationItem.title = self.chattingModule.sessionEntity.name
        self.navigationController?.setNavigationBarHidden(false , animated: true )
        
        DDMessageModule.shareInstance().add(self)
        self.noMoreRecords = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        self.refreshMessagesData(scrollToBottom: true)

        //清空未读 = 0
        self.chattingModule.sessionEntity.unReadMsgCount = 0
        MTTDatabaseUtil.instance().updateRecentSession(self.chattingModule.sessionEntity) { (error ) in
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        DDMessageModule.shareInstance().remove(self)
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
        
        
        
        tableView.addHeader {
            if self.noMoreRecords {
                self.tableView.headerEndRefreshing()
//                self.view.makeToast("没有更多了", duration: 2.5, position: .center, title: nil , image: nil , style: ToastStyle.init(), completion: nil )
                self.view.makeToast("没有更多了")
            }else{
                self.loadMoreHistoryRecords()
            }
        }
        //必须先addHeader 再设置各类Text ,才能起效
        tableView.headerPullToRefreshText = "下拉載入更多"
        tableView.headerReleaseToRefreshText = "鬆開后載入"
        tableView.headerRefreshingText = "正在載入..."
        
    }
    
    
    func loadMoreHistoryRecords(){
        let contentSizeHeightOld:CGFloat = self.tableView.contentSize.height
        let contentOffsetYOld:CGFloat = self.tableView.contentOffset.y
        
        self.chattingModule.loadMoreHistoryCompletion({[weak self ] (count , error ) in
            
            if error != nil  && error!.localizedDescription.length > 0 {
                self?.view.makeToast(error!.localizedDescription)
                self?.tableView.headerEndRefreshing()
                return
            }
            
            if count > 0 {
                self?.refreshMessagesData(scrollToBottom: false)
                self?.tableView.headerEndRefreshing()
                
                let contentSizeHeightNew:CGFloat = self?.tableView.contentSize.height ?? 0
                let contentOffsetYNew:CGFloat = contentSizeHeightNew - contentSizeHeightOld + contentOffsetYOld
                self?.tableView.setContentOffset(CGPoint.init(x: 0, y: contentOffsetYNew), animated: false )
            }else {
                debugPrint("load more history messages for session \(self?.chattingModule.sessionEntity.sessionID ?? "") ,but no more")

                self?.noMoreRecords = true
                self?.tableView.headerEndRefreshing()
            }
        })
    }
    
    
    func refreshMessagesData(scrollToBottom:Bool){
        
        
        self.showingMessages = chattingModule.showingMessages as! [Any]
        
        self.tableView.reloadData()
        if scrollToBottom{
            self.tableView.checkScrollToBottom()
        }
    }
 
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if (object as? ChattingModule) == self.chattingModule  && keyPath == "showingMessages"{
            self.refreshMessagesData(scrollToBottom: false)
        }
    }
    
    //MARK: uitableView datasource/delegate 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count  = self.showingMessages.count
//        print("numberOfRowsInSection showingmessages ",self.showingMessages.count)
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
        self.tableView.checkScrollToBottom()
        
        HMMessageManager.shared.sendNormal(message: msgEntity, session: self.chattingModule.sessionEntity) {[weak self] (message , error ) in
            if error != nil {
                msgEntity.state = .SendFailure
            }else{
                msgEntity.state = message.state
            }
            
            self?.tableView.reloadData()
        }
        
//        DDMessageSendManager.instance().sendMessage(msgEntity, isGroup: self.chattingModule.sessionEntity.isGroupSession, session: self.chattingModule.sessionEntity, completion: {[weak self] (messageentity, error ) in
//            
//            if messageentity != nil {
//                msgEntity.state = messageentity!.state
//            }else {
//                msgEntity.state = .SendFailure
//            }
//            dispatch(after: 0, task: { 
//                self?.tableView.reloadData()
//            })
//        }) {[weak self] (error ) in
//            msgEntity.state = .SendFailure
//            
//            self?.tableView.reloadData()
//        }
        
    }
    
    //MARK: pick/shoot photos
    func onTapMediaItemPick(){
        let imagePickvc:TZImagePickerController = TZImagePickerController.init(maxImagesCount: 1, delegate: self)
        imagePickvc.allowPreview = true
        imagePickvc.allowTakePicture = true
        imagePickvc.allowPickingVideo = false
        imagePickvc.allowPickingGif = false
        imagePickvc.allowCrop = false
        
        self.present(imagePickvc, animated: true , completion: nil )
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
            
            debugPrint("chatting pick && upload image success :\(String(describing: imageURL)) ")
            
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
            debugPrint("chatting pick && upload image error :\(error.debugDescription) ")

            
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
    
    //MARK: 消息管理代理 DDMessageModuleDelegate
    func onReceiveMessage(_ message: MTTMessageEntity!) {
        guard (self.navigationController?.topViewController == self ) else {
            return
        }
        
        print("DDMessageModuleDelegate onReceiveMessage \n",(message.dicValues() as NSDictionary))
        
        if UIApplication.shared.applicationState == .background {
            if message.sessionId == self.chattingModule.sessionEntity.sessionID {
                self.chattingModule.addShowMessage(message)
                self.chattingModule.updateSessionUpdateTime(UInt(message.msgTime))
                
                self.refreshMessagesData(scrollToBottom: true )
            }
            return
        }
        
        if message.sessionId == self.chattingModule.sessionEntity.sessionID {
            self.chattingModule.addShowMessage(message)
            
            self.chattingModule.sessionEntity.lastMsg = message.msgContent
            self.chattingModule.updateSessionUpdateTime(UInt(message.msgTime))

            self.refreshMessagesData(scrollToBottom: true )
            
            DDMessageModule.shareInstance().sendMsgRead(message)
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
        let messageEntity = MTTMessageEntity.init(content: text, module: self.chattingModule, msgContentType: .Text)
        
        MTTDatabaseUtil.instance().insertMessages([messageEntity], success: { }) { (error ) in }
       
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
                let messageEntity = MTTMessageEntity.init(content: msgcontent, module: self.chattingModule, msgContentType: .Emotion)

                MTTDatabaseUtil.instance().insertMessages([messageEntity], success: {
                }) { (error ) in
                }
                self.sendMessage(msgEntity: messageEntity)
            }
        }else{
            let messageEntity = MTTMessageEntity.init(content: "[\(catalogId!)/\(chartletId!)]", module: self.chattingModule, msgContentType: .Emotion)
            
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
        self.audioRecorder?.stop()
        
        if  ZQFileManager.shared.delete(filePath: self.recordVoicePath){
            self.recordVoicePath = ""
        }
        
//        self.recordIndicatorView.removeFromSuperview()
        UIViewController.cancelPreviousPerformRequests(withTarget: self )
        
    }
    func onStartRecording() {
        print("input view onStartRecording")
        
        self.recordVoicePath = TempPath(name: "Voice_\(TIMESTAMP()).acc")
        let url = URL.init(string: self.recordVoicePath)!
        
        do{
            self.audioRecorder = try AVAudioRecorder.init(url: url , settings: self.recordSettings())
        }catch{
            debugPrint("audiorecorder init error \(error.localizedDescription)")
        }
        
        if self.audioRecorder != nil {
            self.audioRecorder?.record()
            self.recordTimeInterval = 0
//            self.recordIndicatorView.recordTime = 0
            
//            self.view.addSubview(self.recordIndicatorView)
//            self.recordIndicatorView.center = self.view.center
//            self.recordIndicatorView.isHidden = false
            self.perform(#selector(self.updateRecordTime), with: nil , afterDelay: 1)

        }else{
            self.view.makeToast("暂时无法录音")
        }
    }
    func onStopRecording() {
        print("input view onStopRecording")
        self.audioRecorder?.stop()
//        self.recordIndicatorView.removeFromSuperview()
        UIViewController.cancelPreviousPerformRequests(withTarget: self )
        
//        let url = URL.init(string: self.recordVoicePath)!
        
        guard let data = NSData.init(contentsOfFile: self.recordVoicePath) else {
            self.view.makeToast("錄音失敗 -1")
            return
        }

        do {
            self.audioPlayer = try  AVAudioPlayer.init(data: data as Data )
        }catch {
            self.view.makeToast("錄音失敗：\(error.localizedDescription)")
        }
        
        
        if audioPlayer != nil {
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            
            if audioPlayer!.duration > 2.0{
                audioPlayer?.play()
                
                let voicePath:String = self.recordVoicePath
                
                let newmessage = MTTMessageEntity.init(content: voicePath, module: self.chattingModule, msgContentType: .Voice)
                newmessage.msgType = .msgTypeSingleAudio
                
                newmessage.info.updateValue(self.recordVoicePath, forKey: voicePath)
                
                MTTDatabaseUtil.instance().insertMessages([newmessage], success: {   }, failure: { (resultStr ) in  })
                
                self.sendMessage(msgEntity: newmessage)
                
            }else{
                self.view.makeToast("錄音時間太短啦")
            }
            debugPrint("onStopRecording  voice file data lenght : \(data.length/1024)KB  duration: \(audioPlayer!.duration)seconds ")
        }else {
            self.view.makeToast("錄音失敗 -2")
        }
    }
    
    func updateRecordTime(){
        self.recordTimeInterval += 1
        
        debugPrint("updateRecordTime updateRecordTime \(self.recordTimeInterval)")
        
//        self.recordIndicatorView.recordTime += 1
        self.chatInputView.updateAudioRecordTime(self.recordTimeInterval)
        self.perform(#selector(self.updateRecordTime), with: nil , afterDelay: 1)
        
    }
    
    func HMChatCellAction(type: HMChatCellActionType, message: MTTMessageEntity?, sourceView: UIView?) {
        
        debugPrint("HMChatCellAction \(type),message \(message?.msgContent ?? "nil msgcontent")")
        
        if type == .sendAgain && message != nil{
            message!.msgTime = UInt32(Date().timeIntervalSince1970)
            message?.state = .Sending
            
            message?.updateToDB(compeletion: nil )
            self.sendMessage(msgEntity: message!)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.audioPlayer = nil
        self.audioRecorder = nil
        
        debugPrint(" audio played done? \(flag)")
    }
    
    func recordSettings()->[String:Any]{
        var recordSetting:[String:Any] = [:]
        recordSetting.updateValue(kAudioFormatLinearPCM, forKey: AVFormatIDKey)     //格式
        recordSetting.updateValue(8000, forKey: AVSampleRateKey)                    //采样率
        recordSetting.updateValue(2, forKey: AVNumberOfChannelsKey)                 //设置通道为单声道
        recordSetting.updateValue(8, forKey: AVLinearPCMBitDepthKey)                //每个采样点位数,分为8,16,24,32
        recordSetting.updateValue(true , forKey: AVLinearPCMIsFloatKey)             //是否使用浮点数采样
        
        return recordSetting
    }
    
}

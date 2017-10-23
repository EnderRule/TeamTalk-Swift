//
//  HMMessageManager.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/24.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

//import UIKit



extension Notification.Name {
    func postWith(object:Any?){
        NotificationCenter.default.post(name: self , object: object)
    }
}

public typealias HMSendMessageCompletion = ((MTTMessageEntity,NSError?)->Void)

public typealias HMSendImageProgress = ((MTTMessageEntity,CGFloat)->Void)

public typealias HMWillSendMessage = ((MTTMessageEntity)->Void)

@objc public  protocol HMMessageDelegate:NSObjectProtocol {
    
    func onReceive(message:MTTMessageEntity)
    
}

public class HMMessageManager: NSObject {
    public  static let  shared = HMMessageManager()
    
    
    
    private var msgDelegates:[HMMessageDelegate] = []
    
    override init() {
        super.init()
        
        self.sendMessageQueue = DispatchQueue.init(label: "com.mogujie.Duoduo.sendMessageSend")
        
        self.setupTimer()
        
        self.p_registerReceiveMessageAPI()
        
        self.p_registerReceiveReadACKAPI()
    }
    
    private func setupTimer(){
        unAckTimer?.invalidate()
        unAckTimer = nil
        
        unAckTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self , selector: #selector(self.p_checkMessageTimeout), userInfo: nil , repeats: true )
        unAckTimer?.fire()
    }
    
   
    
    //MARK: 发消息 相关

    private var seqNo:Int = 0
    
    private var sendMessageQueue:DispatchQueue!
    private var waitToSendMessages:[MTTMessageEntity] = []
    
    private var unAckQueueMessages:[HMMessageAndTime] = []
    private var unAckTimer:Timer?
    private let MessageTimeOutSecond:TimeInterval = 20.0
    
    public func sendNormal(message:MTTMessageEntity,session:MTTSessionEntity,completion:@escaping HMSendMessageCompletion){
        guard message.msgID > 0  else {
            return
        }
        self.sendMessageQueue.async {
            self.seqNo += 1
            message.seqNo = UInt32(self.seqNo)
            
            if message.isImageMessage{
                session.lastMsg = "[圖片]"
            }else if message.isVoiceMessage{
                session.lastMsg = "[語音]"
            }else {
                session.lastMsg = message.msgContent
            }
            
            var msgData:Data = Data()
            if message.isVoiceMessage {
                msgData = message.getUploadVoiceData()
            }else {
                msgData = message.encodeContent().utf8ToData()
                self.unAckQueueAdd(message: message)
            }
            
            let fromid = UInt32(HMLoginManager.shared.currentUser.intUserID)
            let toid = MTTBaseEntity.pbIDFrom(localID: session.sessionID)
            let sendAPI = SendMessageAPI.init(fromUID: fromid, toUID: toid, type: message.msgType, data: msgData)
            sendAPI.request(withParameters: [:], completion: { (respone , error ) in
                if error != nil {
                    message.state = .SendFailure
                    
                    let error = NSError.init(domain: "發送消息失敗", code: 0, userInfo: nil )
                    completion(message,error)
                }else if let resultIDs = respone as? [UInt32] {
                    
                    self.unAckQueueRemove(message: message)
                    
                    message.state = .SendSuccess
                    session.lastMsgID = message.msgID
                    session.timeInterval = TimeInterval(message.msgTime)
                    
                    message.dbDelete(completion: { (success ) in
                        if success {
                            message.msgID = resultIDs[0]
                            message.dbAdd(completion: nil)
                            
                            completion(message,nil )
                        }else{
                            message.dbDelete(completion: { (success ) in
                                message.msgID = resultIDs[0]
                                message.dbAdd(completion: nil)
                                
                                completion(message,nil )
                            })
                        }
                    })
                }
            })
        }
    }
    
    
    public func sendText(content:String,chattingModule:HMChattingModule,completion:@escaping HMSendMessageCompletion){
        let messageEntity = MTTMessageEntity.initWith(content: content, module: chattingModule, msgContentType: .Text)
        self.sendNormal(message: messageEntity, session: chattingModule.sessionEntity, completion: completion)
    }
    
    public func sendVoice(voicePath:String, message:MTTMessageEntity,session:MTTSessionEntity,completion:@escaping HMSendMessageCompletion){
        
        message.msgType = .msgTypeSingleAudio
        message.msgContentType = .Voice
        message.msgContent = voicePath
        message.voiceLocalPath = voicePath
        
        self.sendNormal(message: message, session: session) { (message , error ) in
            completion(message,error)
        }
    }
    
//    public func sendImage(image:UIImage,chattingModule:HMChattingModule,willSend:@escaping HMWillSendMessage,progress:@escaping HMSendImageProgress,completion:@escaping HMSendMessageCompletion){
//        let imagePath = ZQFileManager.shared.tempPathFor(image: image )
//        self.sendImage(imagePath: imagePath, chattingModule: chattingModule,willSend:willSend, progress: progress, completion: completion)
//    }
    
    public func sendImage(imagePath:String,chattingModule:HMChattingModule,willSend:@escaping HMWillSendMessage,progress:@escaping HMSendImageProgress,completion:@escaping HMSendMessageCompletion){
        
        var scale:CGFloat = 1.618
        if let image:UIImage = UIImage.init(contentsOfFile: imagePath){
            scale = image.size.width/image.size.height
        }
        
        let newMessage:MTTMessageEntity = MTTMessageEntity.initWith(content: "[圖片]", module: chattingModule, msgContentType: DDMessageContentType.Image)
        newMessage.imageLocalPath = imagePath
        newMessage.imageScale = scale
        newMessage.msgContentType = .Image
        newMessage.dbSave(completion: nil)
        
        willSend(newMessage)
        
        //先上传图片、再发送含有图片URL 的消息。
        SendPhotoMessageAPI.shared.uploadPhoto(imagePath: imagePath, to: chattingModule.sessionEntity, progress: { (pro ) in
            
            let floatProgress = CGFloat(pro.completedUnitCount)/CGFloat(pro.totalUnitCount)
            progress(newMessage,floatProgress)
            
        }, success: {[weak self] (imageURL ) in
//            HMPrint("upload success url: \(imageURL)")
            
            if imageURL.length > 0 {
                newMessage.state = .Sending
                
                newMessage.imageUrl = imageURL
                
                newMessage.updateToDB(compeletion: nil)
                
                self?.sendNormal(message: newMessage, session: chattingModule.sessionEntity, completion: { (message , error ) in
                    completion(message,error)
                })
            }
        }) {  (errorString ) in
            
            newMessage.state = .SendFailure
            newMessage.updateToDB(compeletion: { (success ) in })
            
            completion(newMessage,NSError.init(domain: "image upload failure", code: 0, userInfo: nil))
        }
    }
    
    
    //MARK: UnAckQueue and Timer func
    private func unAckQueueAdd(message:MTTMessageEntity){
        let mat = HMMessageAndTime.init()
        mat.msg = message
        mat.nowDate = Date().timeIntervalSince1970
        
        self.unAckQueueMessages.append(mat)
        
        self.setupTimer()
    }
    
    private func unAckQueueRemove(message:MTTMessageEntity){
        for obj in self.unAckQueueMessages{
            if obj.msg.msgID == message.msgID {
                let index = self.unAckQueueMessages.index(of: obj)
                if index != nil {
                    self.unAckQueueMessages.remove(at: index!)
                }
                
                break
            }
        }
    }
    private func isInUnAckQueue(message:MTTMessageEntity)->Bool {
        for obj in self.unAckQueueMessages{
            if obj.msg.msgID == message.msgID {
                return true
            }
        }
        return false
    }
    
    @objc private func p_checkMessageTimeout(){
//        HMPrint("\(self.classForCoder) checkMessageTimeout messagesCount\(self.unAckQueueMessages.count)")
       
        if unAckQueueMessages.count == 0{
            self.unAckTimer?.invalidate()
            self.unAckTimer = nil
        }else {
            for obj in self.unAckQueueMessages.enumerated(){
                let timeNow = Date().timeIntervalSince1970
                let msgTimeout = obj.element.nowDate + self.MessageTimeOutSecond
                if timeNow >= msgTimeout {
                    obj.element.msg.state = .SendFailure
                    obj.element.msg.updateToDB(compeletion: nil)
                    
                    self.unAckQueueRemove(message: obj.element.msg)
                }
            }
        }
    }
    
    //MARK: 收消息相关
    private var receiveMsgApi:ReceiveMessageAPI = ReceiveMessageAPI.init()
    private var receiveReadedMsgApi:MsgReadNotifyAPI = MsgReadNotifyAPI.init()
    private var unreadMessages:[MTTMessageEntity] = []
    
    var unreadMsgCount:Int{
        get{
            return unreadMessages.count
        }
    }
    func removeAllUnreadMessages(){
        unreadMessages.removeAll()
    }
    
    
    public  func getMsgFromServer(beginMsgID:UInt32,forSession:MTTSessionEntity,count:Int,completion:@escaping (([MTTMessageEntity],Error?)->Void)){
        let sessionID = MTTBaseEntity.pbIDFrom(localID: forSession.sessionID)
        
        let api:GetMessageQueueAPI = GetMessageQueueAPI.init(sessionID: sessionID, sessionType:forSession.sessionType, msgIDBegin: beginMsgID, count: count)
        api.request(withParameters: [:]) { (messages , error ) in
            completion(messages as? [MTTMessageEntity] ?? [],error)
        }
    }
    
    /// 收到消息
    private func p_registerReceiveMessageAPI(){
        receiveMsgApi.registerAPI { (obj , error ) in
            if let message = obj as? MTTMessageEntity {
                message.state = .SendSuccess
                
                //发送收到消息的回执
                self.sendReceiveACK(message: message)
                
                if message.isGroupMessage { // 如果是群消息且用户已屏蔽该群，则可以直接发送已读回执
                    if let  group = HMGroupsManager.shared.groupFor(ID: message.sessionId){
                        if group.isShield{
                            self.sendReadACK(message: message)
                        }
                    }
                }
                
                HMNotification.receiveMessage.postWith(obj: message, userInfo: nil )
            }
        }
    }
    
    ///  收到已读回执
    private func p_registerReceiveReadACKAPI(){
        receiveReadedMsgApi.registerAPI { (obj , error ) in
            let dic = obj as! [String:Any]
            if dic.count > 0 {
                let fromID = dic["from_id"] as? UInt32 ?? 0
                let type = dic["type"] as? Int ?? 1
                let msgID = dic["msgId"] as? UInt32 ?? 0
                let sessionType:SessionType_Objc = type == 1 ? .sessionTypeSingle:.sessionTypeGroup
                let sessionID:String = sessionType == .sessionTypeSingle ? MTTUserEntity.localIDFrom(pbID: fromID) : MTTGroupEntity.localIDFrom(pbID: fromID)
                
                HMPrint("收到已读回执：\(msgID) \(sessionID)")
                
                MTTMsgReadState.save(msgID: msgID, sessionID: sessionID, state: .Readed)
                
//                MTTMessageEntity.dbQuery(whereStr: "msgID = \(msgID)", orderFields: nil, offset: 0, limit: 1, args: [], completion: { (messages , error ) in
//                    if let message = messages.first as? MTTMessageEntity{
//                        message.state = .Readed
//                        message.dbSave(completion: { (success )in
//                            HMPrint("db 更新已读回执：\(success) \(msgID) \(sessionID) \(message.msgContent)")
//                        })
//                    }
//                })

                HMSessionModule.shared.cleanMsgFromNotific(messageID: msgID, sessionID: sessionID, sessionType: sessionType)
            }
        }
    }
    
    //MARK: 消息回执相关
    /// 发送收到消息的回执
    ///
    /// - Parameter message: 消息实体
    public func sendReceiveACK(message:MTTMessageEntity){
        let sessionID = MTTBaseEntity.pbIDFrom(localID: message.sessionId)
        let api:ReceiveMessageACKAPI = ReceiveMessageACKAPI.init(msgID: message.msgID, sessionID: sessionID, sessionType: message.sessionType)
        api.request(withParameters: [:]) { (obj , error ) in
        }
    }
    public func sendReceiveACK(msgID:UInt32,sessionID:String,sessionType:SessionType_Objc){
        let sessionID = MTTBaseEntity.pbIDFrom(localID: sessionID)
        let type:Im.BaseDefine.SessionType = sessionType == .sessionTypeSingle ? .sessionTypeSingle : .sessionTypeGroup
        let api:ReceiveMessageACKAPI = ReceiveMessageACKAPI.init(msgID: msgID, sessionID: sessionID, sessionType: type)
        api.request(withParameters: [:]) { (obj , error ) in
        }

    }
    
    
    /// 发送已读回执
    ///
    /// - Parameter message: 消息实体
    public func sendReadACK(message:MTTMessageEntity){
        let sessionID = MTTBaseEntity.pbIDFrom(localID: message.sessionId)
        let api:MsgReadACKAPI = MsgReadACKAPI.init(sessionID: sessionID, msgID: message.msgID, sessionType: message.sessionType)
        api.request(withParameters: [:]) { (obj , error ) in
            
            if obj as? Bool ?? false {
                MTTMsgReadState.save(message:message, state: .Readed)
            }
        }
    }
    public func sendReadACK(msgID:UInt32,sessionID:String,sessionType:SessionType_Objc){
        let sessionIDInt = MTTBaseEntity.pbIDFrom(localID: sessionID)
        let type:Im.BaseDefine.SessionType = sessionType == .sessionTypeSingle ? .sessionTypeSingle : .sessionTypeGroup
        let api:MsgReadACKAPI = MsgReadACKAPI.init(sessionID: sessionIDInt, msgID: msgID, sessionType: type)
        api.request(withParameters: [:]) { (obj , error ) in
            if obj as? Bool ?? false {
                MTTMsgReadState.save(msgID: msgID, sessionID: sessionID, state: .Readed)
            }
        }
    }
}



class HMMessageAndTime : NSObject {
    var msg:MTTMessageEntity = MTTMessageEntity.init()
    var nowDate:TimeInterval = 0
}

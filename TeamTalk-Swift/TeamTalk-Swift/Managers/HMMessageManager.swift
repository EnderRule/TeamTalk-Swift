//
//  HMMessageManager.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/24.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let HMSendMessageSuccessfull:Notification.Name = Notification.Name.init("SentMessageSuccessfull")
}

extension Notification.Name {
    
    func postWith(object:Any?){
        NotificationCenter.default.post(name: self , object: object)
    }
}

typealias HMSendMessageCompletion = ((MTTMessageEntity,NSError?)->Void)

class HMMessageManager: NSObject {
    static let  shared = HMMessageManager()
    private var seqNo:Int = 0
    
    private var sendMessageQueue:DispatchQueue!
    private var waitToSendMessages:[MTTMessageEntity] = []
    
    
    private var unAckQueueMessages:[HMMessageAndTime] = []
    private var unAckTimer:Timer?
    private let MessageTimeOutSecond:TimeInterval = 20.0
    
    override init() {
        super.init()
        
        self.sendMessageQueue = DispatchQueue.init(label: "com.mogujie.Duoduo.sendMessageSend")
        
        self.setupTimer()
    }
    
    private func setupTimer(){
        unAckTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self , selector: #selector(self.checkMessageTimeout), userInfo: nil , repeats: true )
    }
    
    public func sendNormal(message:MTTMessageEntity,session:MTTSessionEntity,completion:@escaping HMSendMessageCompletion){
        guard message.msgID > 0  else {
            return
        }
        self.sendMessageQueue.async {
            self.seqNo += 1
            message.seqNo = self.seqNo
            
            if message.isImageMessage{
                session.lastMsg = "[圖片]"
            }else if message.isVoiceMessage{
                session.lastMsg = "[語音]"
            }else {
                session.lastMsg = message.msgContent
            }
            
            var msgData:Data = Data()
            if message.isVoiceMessage {
                msgData = self.getUploadVoiceDataAt(message: message)
            }else {
                var msgContent:String = message.msgContent
                if message.isImageMessage {
                    let dic:NSDictionary = NSDictionary.initWithJsonString(message.msgContent)! as NSDictionary
                    let imageurl = dic[MTTMessageEntity.DD_IMAGE_URL_KEY] as! String
                    msgContent = imageurl
                }
                msgData = msgContent.encrypt().utf8ToData()
                self.unAckQueueAdd(message: message)
            }
            
            Notification.Name.HMSendMessageSuccessfull.postWith(object: session)
           
            let packObject:[Any] = [RuntimeStatus.instance().user.userId,session.sessionID,msgData,message.msgType.rawValue,message.msgID]
            debugPrint("HMMessageManager send message \(message.dicValues() as Dictionary) \n packObject \(packObject as Array)")
            
            let sendAPI = SendMessageAPI.init()
            sendAPI.request(with: packObject, completion: { (respone , error ) in
                if error != nil {
                    message.state = .SendFailure
                    
                    MTTDatabaseUtil.instance().insertMessages([message], success: {  }, failure: { (errorString ) in })
                
                    let error = NSError.init(domain: "發送消息失敗", code: 0, userInfo: nil )
                    completion(message,error)
                }else if let resultIDs = respone as? [UInt32] {
                    MTTDatabaseUtil.instance().deleteMesages(message, completion: { ( success ) in  })
                    

                    self.unAckQueueRemove(message: message)
                    
                    message.msgID = resultIDs[0]
                    message.state = .SendSuccess
                    
                    session.lastMsgID = message.msgID
                    session.timeInterval = TimeInterval(message.msgTime)
                    
                    MTTDatabaseUtil.instance().insertMessages([message], success: {   }, failure: { (errorString ) in  })
                    Notification.Name.HMSendMessageSuccessfull.postWith(object: session)
                    
                    completion(message,nil )
                }
            })
        }
    }
    
    
    public func sendVoice(voicePath:String, message:MTTMessageEntity,session:MTTSessionEntity,completion:@escaping HMSendMessageCompletion){
//        let voiceDuration = HMMediaManager.shared.durationFor(filePath: voicePath)
        
//        if voiceDuration > 1{
        
            message.msgType = .msgTypeSingleAudio
            message.msgContentType = .Voice
            message.msgContent = voicePath
            message.info.updateValue(voicePath, forKey: MTTMessageEntity.VOICE_LOCAL_KEY)
            
            self.sendNormal(message: message, session: session) { (message , error ) in
                completion(message,error)
            }
//        }else{
//            completion(message,NSError.init(domain: "錄音時間太短", code: 0, userInfo: nil))
//        }
    }
    
    public func sendImage(imagePath:String,message:MTTMessageEntity,session:MTTSessionEntity,completion:HMSendMessageCompletion){
        message.msgContentType = .Image
        
        
    }
    
    
    
    //MARK: UnAckQueue and Timer func
    func unAckQueueAdd(message:MTTMessageEntity){
        let mat = HMMessageAndTime.init()
        mat.msg = message
        mat.nowDate = Date().timeIntervalSince1970
        
        self.unAckQueueMessages.append(mat)
    }
    
    func unAckQueueRemove(message:MTTMessageEntity){
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
    func isInUnAckQueue(message:MTTMessageEntity)->Bool {
        for obj in self.unAckQueueMessages{
            if obj.msg.msgID == message.msgID {
                return true
            }
        }
        return false
    }
    
    func checkMessageTimeout(){
        debugPrint("\(self.classForCoder) checkMessageTimeout messagesCount\(self.unAckQueueMessages.count)")
        for obj in self.unAckQueueMessages.enumerated(){
            let timeNow = Date().timeIntervalSince1970
            let msgTimeout = obj.element.nowDate + self.MessageTimeOutSecond
            if timeNow >= msgTimeout {
                obj.element.msg.state = .SendFailure
                MTTDatabaseUtil.instance().updateMessage(forMessage: obj.element.msg, completion: { ( issuccess ) in  })
                self.unAckQueueRemove(message: obj.element.msg)
            }
        }
    }
    
    
    func getUploadVoiceDataAt(message:MTTMessageEntity)->Data{
        let localPath = message.msgContent.safeLocalPath()
        if FileManager.default.fileExists(atPath: localPath){
            do {
                let voicedata = try  NSData.init(contentsOfFile: localPath) as Data
                
                let json = JSON.init(message.info)
                let length:Int = json[MTTMessageEntity.VOICE_LENGTH].intValue
                let muData:NSMutableData = NSMutableData.init()
                for index in 0..<4 {
                    var byte = ((length >> ((3 - index)*8)) & 0x0ff)
                    muData.append(&byte, length: 1)
                }
                muData.append(voicedata)
                
                return muData as Data
            }catch {
                return Data()
            }
        }else {
            return Data()
        }
        
//        let localPath:String = message.msgContent.safeLocalPath() // message.info[MTTMessageEntity.VOICE_LOCAL_KEY] as? String ?? ""
//        if FileManager.default.fileExists(atPath: localPath){
//            do {
//                msgData =  try  NSData.init(contentsOfFile: localPath) as Data
//                
//                debugPrint("HMMessageManager send voice data \(msgData.endIndex/1024) KB")
//            }catch {
//                let errorString = "send voice message read data error :\(error.localizedDescription)  \n at path \(localPath)"
//                let error = NSError.init(domain: errorString, code: 0, userInfo: nil )
//                completion(message,error)
//                return
//            }
//        }else {
//            let errorString = "send voice message file do not exist at path \(localPath)"
//            let error = NSError.init(domain: errorString, code: 0, userInfo: nil )
//            completion(message,error)
//            return
//        }
    }
}


class HMMessageAndTime : NSObject {
    var msg:MTTMessageEntity = MTTMessageEntity.init()
    var nowDate:TimeInterval = 0
}

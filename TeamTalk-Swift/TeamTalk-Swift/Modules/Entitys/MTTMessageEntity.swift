//
//  MTTMessageEntity.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

@objc enum DDMessageContentType:Int {
    case Text      = 0
    case Image     = 1
    case Voice     = 2
    case Emotion        = 3
    case Audio          = 100
    case GroupAudio     = 101
}

@objc enum DDMessageState:Int{
    case Sending = 0
    case SendFailure = 1
    case SendSuccess = 2
}

@objc public enum MsgType_Objc:Int32 {
    case msgTypeSingleText = 1
    case msgTypeSingleAudio = 2
    case msgTypeGroupText = 17
    case msgTypeGroupAudio = 18
    public func toString() -> String {
        switch self {
        case .msgTypeSingleText: return "MSG_TYPE_SINGLE_TEXT"
        case .msgTypeSingleAudio: return "MSG_TYPE_SINGLE_AUDIO"
        case .msgTypeGroupText: return "MSG_TYPE_GROUP_TEXT"
        case .msgTypeGroupAudio: return "MSG_TYPE_GROUP_AUDIO"
        }
    }
    public static func fromString(_ str:String) throws -> MsgType_Objc {
        switch str {
        case "MSG_TYPE_SINGLE_TEXT":    return .msgTypeSingleText
        case "MSG_TYPE_SINGLE_AUDIO":    return .msgTypeSingleAudio
        case "MSG_TYPE_GROUP_TEXT":    return .msgTypeGroupText
        case "MSG_TYPE_GROUP_AUDIO":    return .msgTypeGroupAudio
        default: return .msgTypeSingleText
        }
    }
    public var debugDescription:String { return getDescription() }
    public var description:String { return getDescription() }
    private func getDescription() -> String {
        switch self {
        case .msgTypeSingleText: return ".msgTypeSingleText"
        case .msgTypeSingleAudio: return ".msgTypeSingleAudio"
        case .msgTypeGroupText: return ".msgTypeGroupText"
        case .msgTypeGroupAudio: return ".msgTypeGroupAudio"
        }
    }
    public var hashValue:Int {
        return self.rawValue.hashValue
    }
    public static func ==(lhs:MsgType_Objc, rhs:MsgType_Objc) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}


class MTTMessageEntity: NSObject {
    
    
    
    var msgID:UInt32 = 0
    var msgType:MsgType_Objc = .msgTypeSingleText
    var msgTime:UInt32 = 0
    var sessionId:String = ""
    var seqNo:Int = 0
    var senderId:String = ""
    var msgContent:String = ""
    var toUserID:String = ""
    var info:[String:Any] = [:]  //附加属性、包括语音时长
    var msgContentType:DDMessageContentType = .Text
    var attach:String = ""
    var sessionType:Im.BaseDefine.SessionType = .sessionTypeSingle
    var state:DDMessageState = .Sending
    
    
    public convenience init(msgID:UInt32,msgType:MsgType_Objc,msgTime:UInt32,sessionID:String,senderID:String,msgContent:String,toUserID:String){
        self.init()
        
        self.msgID = msgID
        self.msgType = msgType
        self.msgTime = msgTime
        self.sessionId = sessionID
        self.senderId = senderID
        self.toUserID = toUserID
        self.msgContent = msgContent
        
    }
    
    public convenience init(content:String,module:ChattingModule,msgContentType:DDMessageContentType){
        self.init()
        
        if module.sessionEntity.sessionType == .sessionTypeGroup{
            self.msgType = .msgTypeGroupText
        }else{
            self.msgType = .msgTypeSingleText
        }
        self.msgContent = content
        self.msgContentType = msgContentType
        self.msgID = UInt32(DDMessageModule.getMessageID())
        self.sessionId = module.sessionEntity.sessionID
        self.toUserID = module.sessionEntity.sessionID
        self.senderId = RuntimeStatus.instance().user.userId
        self.state = .Sending
        self.msgTime = UInt32(Date().timeIntervalSince1970)

        module.addShowMessage(self)
        module.updateSessionUpdateTime(UInt(self.msgTime))
    }
    
    var isGroupMessage:Bool {
        get{
            return ( self.msgType == .msgTypeGroupAudio || self.msgType == .msgTypeGroupText)
        }
    }
    var isVoiceMessage:Bool {
        get {
            return ( self.msgType == .msgTypeGroupAudio || self.msgType == .msgTypeSingleAudio)
        }
    }
    var isGroupVoiceMessage:Bool {
        get {
            return self.msgType == .msgTypeGroupAudio
        }
    }
    var isImageMessage:Bool {
        return self.msgContentType == .Image
    }
    var isSendBySelf:Bool {
       return  self.senderId == RuntimeStatus.instance().user.objID
    }
    var isEmotionMsg:Bool{
        return false
//        return   [[[EmotionsModule shareInstance].emotionUnicodeDic allKeys] containsObject:self.msgContent];
    }
}

extension MTTMessageEntity {
    
    static  let  DDVOICE_PLAYED:String              =       "voicePlayed"
    static  let  VOICE_LENGTH:String                =       "voiceLength"
    static  let  DD_IMAGE_LOCAL_KEY :String         =       "local"
    static  let  DD_IMAGE_URL_KEY :String           =       "url"

    static  let  DD_COMMODITY_ORGPRICE:String        =       "orgprice"
    static  let  DD_COMMODITY_PICURL:String          =       "picUrl"
    static  let  DD_COMMODITY_PRICE:String           =       "price"
    static  let  DD_COMMODITY_TIMES:String           =       "times"
    static  let  DD_COMMODITY_TITLE :String          =       "title"
    static  let  DD_COMMODITY_URL:String             =       "URL"
    static  let  DD_COMMODITY_ID:String              =       "CommodityID"
    
}

extension MTTMessageEntity {
    public convenience init(msgInfo:Im.BaseDefine.MsgInfo,sessionType:Im.BaseDefine.SessionType){
        self.init()
        
        self.msgTime =  msgInfo.createTime
        //Fixme: upate values here

    }
    
    public convenience init(msgData:Im.Message.ImmsgData){
        self.init()
        
        self.msgTime = msgData.createTime
        
        self.msgType = MsgType_Objc.init(rawValue: msgData.msgType.rawValue) ?? .msgTypeSingleText
        
        self.sessionType = self.isGroupMessage ? .sessionTypeGroup: .sessionTypeSingle

        var msgInfo:[String:Any] = [:]
        if self.isVoiceMessage {
            self.msgContentType = .Voice
            
            if (msgData.msgData as NSData).length > 4 {
                self.process(voiceData: msgData.msgData, compeletion: { (filepath , voiceLength) in
                    self.msgContent = filepath
                    
                    msgInfo.updateValue(voiceLength, forKey: MTTMessageEntity.VOICE_LENGTH )
                    msgInfo.updateValue(0, forKey: MTTMessageEntity.DDVOICE_PLAYED)
                })
            }else {
                self.msgContent = "語音存儲出錯"
            }
        }else{
            if let tempStr = String.init(data: msgData.msgData, encoding: .utf8){
                let indata = tempStr.cString(using: .utf8)
                var pout:UnsafeMutablePointer<Int8>?
                var outLen:UnsafeMutablePointer<UInt32>?
                let inLen:Int32 = Int32(strlen(tempStr))
            
                DecryptMsg(indata, inLen, &pout, &outLen)
                
                if pout != nil {
                    let decodeMsg = String.init(cString: pout!)
                    self.msgContent = decodeMsg
                }
            }else{
                debugPrint(self.classForCoder,"init with msgData、convert error")
            }
        }
        
        if self.sessionType == .sessionTypeSingle{
            self.sessionId = MTTUserEntity.localIDFrom(pbID: msgData.fromUserId)
        }else {
            self.sessionId = MTTGroupEntity.localIDFrom(pbID: msgData.toSessionId)
        }
        
        if self.isEmotionMsg{
            self.msgContentType = .Emotion
        }
        self.msgID = msgData.msgId
        self.toUserID = self.sessionId
        self.senderId = MTTUserEntity.localIDFrom(pbID: msgData.fromUserId)
        
        self.info = msgInfo
    }
    
    private func process(voiceData:Data, compeletion: @escaping ((_ voiceFilePath:String,_ voiceLength:Int32) ->Void)){
        
        let tempData:NSData = voiceData as NSData
        let voiceData:NSData = tempData.subdata(with: .init(location: 4, length: tempData.length - 4)) as NSData
        let fileName:String = Encapsulator.defaultFileName()
        
        var filePath:String = ""
        if voiceData.write(toFile: fileName, atomically: true){
            filePath = fileName
        }else{
            filePath = "語音存儲出錯"
        }
        
        var ch1:Int32 = 0
        var ch2:Int32 = 0
        var ch3:Int32 = 0
        var ch4:Int32 = 0
        voiceData.getBytes(&ch1, range: NSRange.init(location: 0, length: 1))
        voiceData.getBytes(&ch2, range: NSRange.init(location: 1, length: 1))
        voiceData.getBytes(&ch3, range: NSRange.init(location: 2, length: 1))
        voiceData.getBytes(&ch4, range: NSRange.init(location: 3, length: 1))
        ch1 = ch1 & 0x0ff
        ch2 = ch2 & 0x0ff
        ch3 = ch3 & 0x0ff
        ch4 = ch4 & 0x0ff
        if ((ch1 | ch2 | ch3 | ch4) < 0){
            debugPrint(self.classForCoder,"init with msgData 、parse voice EOFException")
        }
        let voiceLength:Int32 = ((ch1 << 24) + (ch2 << 16) + (ch3 << 8) + (ch4 << 0))
        
        compeletion(filePath,voiceLength)
    }
}


extension String {
    
    func decrypt()->String {
     let tempStr = self
        let indata = tempStr.cString(using: .utf8)
        var pout:UnsafeMutablePointer<Int8>?
        var outLen:UnsafeMutablePointer<UInt32>?
        let inLen:Int32 = Int32(strlen(tempStr))
        
        DecryptMsg(indata, inLen, &pout, &outLen)
        
        if pout != nil {
            let deResult = String.init(cString: pout!)
            return deResult
        }
        return ""
    }
    
    func encrypt()->String {
        let tempStr = self
        let indata = tempStr.cString(using: .utf8)
        var pout:UnsafeMutablePointer<Int8>?
        var outLen:UnsafeMutablePointer<UInt32>?
        let inLen:Int32 = Int32(strlen(tempStr))
        
        EncryptMsg(indata, inLen, &pout, &outLen)
        
        if pout != nil {
            let enResult = String.init(cString: pout!)
            return enResult
        }
        return ""
    }
}

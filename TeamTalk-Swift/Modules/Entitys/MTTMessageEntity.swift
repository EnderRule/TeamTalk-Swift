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


//messageID integer,
//sessionId text ,
//fromUserId text,
//toUserId text,
//content text,
//status integer,
//msgTime real,
//sessionType integer,
//messageContentType integer,
//messageType integer,
//info text,
//reserve1 integer,
//reserve2 text,
//primary key (messageID,sessionId)

@objc(MTTMessageEntity)
class MTTMessageEntity: MTTBaseEntity,HMDBModelDelegate {
    
    func dbFields() -> [String] {
        return ["msgID","msgTime","seqNo",
                "sessionId","senderId","toUserID",
                "msgContent","attach","extraInfo",
                "msgContentTypeInt","sessionTypeInt","msgTypeInt","stateInt"]
    }
    func dbPrimaryKey() -> String? {
        return "msgID"
    }
    
    let primaryKeyName:String = "msgID"

    var msgID:UInt32 = 0
    var msgTime:UInt32 = 0
    var seqNo:UInt32 = 0
    var sessionId:String = ""
    var senderId:String = ""
    var toUserID:String = ""
    var msgContent:String = ""
    var attach:String = ""
    var extraInfo:[String:Any] = [:]

    var msgContentTypeInt:Int16 = Int16(DDMessageContentType.Text.rawValue)
    var sessionTypeInt:Int16 = Int16(SessionType_Objc.sessionTypeSingle.rawValue)
    var msgTypeInt:Int16 = Int16(MsgType_Objc.msgTypeSingleText.rawValue)
    var stateInt:Int16 = Int16(DDMessageState.SendSuccess.rawValue)

    var msgContentType:DDMessageContentType{
        set{
            self.msgContentTypeInt = Int16(newValue.rawValue)
        }
        get{
            return DDMessageContentType.init(rawValue: Int(self.msgContentTypeInt))!
        }
        
    }
    
    var sessionType:Im.BaseDefine.SessionType{
        set{
            self.sessionTypeInt = Int16(newValue.rawValue)
        }
        get{
            return self.sessionTypeInt == 1 ? Im.BaseDefine.SessionType.sessionTypeSingle : Im.BaseDefine.SessionType.sessionTypeGroup
        }
    }
    var msgType:MsgType_Objc{
        set{
            self.msgTypeInt = Int16(newValue.rawValue)
        }
        get{
            return MsgType_Objc.init(rawValue: Int32(self.msgTypeInt))!
        }
        
    }
    var state:DDMessageState{
        set{
            self.stateInt = Int16(newValue.rawValue)
        }
        get{
            return DDMessageState.init(rawValue: Int(self.stateInt))!
        }
        
    }
 
    var isGroupMessage:Bool {
        get{
            return ( self.msgType == .msgTypeGroupAudio || self.msgType == .msgTypeGroupText)
        }
    }
    var isVoiceMessage:Bool {
        get {
            return ( self.msgType == .msgTypeGroupAudio || self.msgType == .msgTypeSingleAudio || self.msgContentType == .Voice)
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
       return  self.senderId == HMCurrentUser().userId
    }
    var isEmotionMsg:Bool{
        return   self.msgContentType == .Emotion
    }
    var isValide:Bool {
        return self.msgID > 0 && msgContent.characters.count > 0 && senderId.characters.count > 0 && sessionId.characters.count > 0
    }
    ///初始值
//    override func awakeFromInsert() {
//        super.awakeFromInsert()
//        
//        self.msgID = 0
//        self.msgTime = 0
//        self.sessionId = ""
//        self.seqNo = 0
//        self.senderId = ""
//        self.msgContent = ""
//        self.toUserID = ""
//        self.attach  = ""
//        self.extraInfo = [:]
//        self.msgContentType = .Text
//        self.sessionType = .sessionTypeSingle
//        self.msgType = .msgTypeSingleText
//        self.state = .SendSuccess
//
//    }
//    
//    override func awakeFromFetch() {
//        super.awakeFromFetch()
//        
//        self.msgID = 0
//        self.msgTime = 0
//        self.sessionId = ""
//        self.seqNo = 0
//        self.senderId = ""
//        self.msgContent = ""
//        self.toUserID = ""
//        self.attach  = ""
//        self.extraInfo = [:]
//        self.msgContentType = .Text
//        self.sessionType = .sessionTypeSingle
//        self.msgType = .msgTypeSingleText
//        self.state = .SendSuccess
//    }
}

extension MTTMessageEntity {
    //聲音消息
    static let kVoiceHadPlayed:String             = "voiceHadPlayed"
    static let kVoiceLength:String                = "voiceLength"
    static let kVoiceLocalPath:String             = "voiceLocalPath"
    var voiceHadPlayed:Bool{
        get{
            return self.extraInfo[MTTMessageEntity.kVoiceHadPlayed] as? Bool ?? false
        }
        set{
            self.extraInfo.updateValue(newValue, forKey: MTTMessageEntity.kVoiceHadPlayed)
        }
    }
    var voiceLocalPath:String{
        get{
            return (self.extraInfo[MTTMessageEntity.kVoiceLocalPath] as? String ?? "").safeLocalPath()
        }
        set{
            self.extraInfo.updateValue(newValue, forKey: MTTMessageEntity.kVoiceLocalPath)
        }
    }
    var voiceLength:Int{
        get{
            return self.extraInfo[MTTMessageEntity.kVoiceLength] as? Int ?? 0
        }
        set{
            self.extraInfo.updateValue(newValue, forKey: MTTMessageEntity.kVoiceLength)
        }
    }
    
    //圖片消息
    static let kImageLocalPath :String            = "imageLocalPath"
    static let kImageUrl :String                  = "imageUrl"
    static let kImageScale:String                 = "imageScale"
    var imageLocalPath:String{
        get{
            return (self.extraInfo[MTTMessageEntity.kImageLocalPath] as? String ?? "").safeLocalPath()
        }
        set{
            self.extraInfo.updateValue(newValue, forKey: MTTMessageEntity.kImageLocalPath)
        }
    }
    var imageUrl:String{
        get{
            return self.extraInfo[MTTMessageEntity.kImageUrl] as? String ?? ""
        }
        set{
            self.extraInfo.updateValue(newValue, forKey: MTTMessageEntity.kImageUrl)
        }
    }
    var imageScale:CGFloat{
        get{
            return self.extraInfo[MTTMessageEntity.kImageScale] as? CGFloat ?? 1.618
        }
        set{
            self.extraInfo.updateValue(newValue, forKey: MTTMessageEntity.kImageScale)
        }
    }

    //MARK:貼圖表情
    static let kEmojiText:String                  = "emojiText"
    static let kEmojiCategory:String              = "emojiCategory"
    static let kEmojiName:String                  = "emojiName"
    var emojiText:String{
        get{
            return self.extraInfo[MTTMessageEntity.kEmojiText] as? String ?? ""
        }
        set{
            self.extraInfo.updateValue(newValue, forKey: MTTMessageEntity.kEmojiText)
        }
    }
    var emojiCategory:String{
        get{
            return self.extraInfo[MTTMessageEntity.kEmojiCategory] as? String ?? ""
        }
        set{
            self.extraInfo.updateValue(newValue, forKey: MTTMessageEntity.kEmojiCategory)
        }
    }
    var emojiName:String{
        get{
            return self.extraInfo[MTTMessageEntity.kEmojiName] as? String ?? ""
        }
        set{
            self.extraInfo.updateValue(newValue, forKey: MTTMessageEntity.kEmojiName)
        }
    }
    
}

extension MTTMessageEntity {
    
//    文本 {"type":10,"data":"{\"text\":\"ghj\"}"}
//    圖片 {"type":11,"data":"{\"url\":\"http:.......789000.jpg\"}"}
//    表情 {"type":12,"data":"{\"sticker\":\"xxx\"}"}
    
    public class func pb_decode(content:String)->String{
        var msgContent:String = ""

        let realConent = content.decrypt()
        let dic = NSDictionary.initWithJsonString(realConent) ?? [:]
        let json = JSON.init(dic)
        let type = json["type"].intValue
        if type == 10 {
            msgContent = json["data"]["text"].stringValue
        }else if type == 11 {
            msgContent = "[圖片]"
        }else if type == 12{
            msgContent = json["data"]["text"].stringValue
        }else{
            msgContent = "[未知消息]"
        }
        return msgContent
    }
    
    public func decode(content:String){
        
        let realConent = content.decrypt()
        let dic = NSDictionary.initWithJsonString(realConent) ?? [:]
        
//        NSLog("MTTMessageEntity decode \ndic:%@",realConent,dic as NSDictionary )
        
        let json = JSON.init(dic)

        let type = json["type"].intValue
        
        if type == 10 {
            self.msgContentType = .Text
            self.msgContent = json["data"]["text"].stringValue
        }else if type == 11 {
            self.msgContentType = .Image

            self.imageUrl = json["data"]["url"].stringValue
            self.imageScale = CGFloat(json["data"]["scale"].floatValue)
 
            self.msgContent = "[圖片]"
        }else if type == 12{
            self.msgContentType = .Emotion
            
            self.emojiName = json["data"]["name"].stringValue
            self.emojiCategory = json["data"]["category"].stringValue
            self.emojiText = json["data"]["text"].stringValue
 
            self.msgContent = json["data"]["text"].stringValue
        }else{
            self.msgContentType = .Text
            self.msgContent = "[未知消息]"
        }
    }
    
    public func encodeContent()->String{
        var dataDic:[AnyHashable:Any] = [:]
        var type:Int = 0
        if self.msgContentType == .Text {
            dataDic.updateValue(self.msgContent, forKey: "text")
            type = 10
        }else if self.msgContentType == .Image{
            dataDic.updateValue(self.imageUrl, forKey: "url")
            dataDic.updateValue(self.imageScale, forKey: "scale")
            
            type = 11
        }else if self.msgContentType == .Emotion  {
            dataDic.updateValue(self.emojiText, forKey: "text")
            dataDic.updateValue(self.emojiCategory, forKey: "category")
            dataDic.updateValue(self.emojiName, forKey: "name")

            type = 12
        }
        
        var dic:[AnyHashable:Any] = [:]
        dic.updateValue(type, forKey: "type")
        dic.updateValue(dataDic, forKey: "data")

        NSLog("MTTMessageEntity encode \ndic:%@",dic as NSDictionary )
        
        let contentStr:String = (dic as NSDictionary).jsonString() ?? ""
        let encryptContent:String = contentStr.encrypt()
        
        return encryptContent
    }
    
    public class func  initWith(msgID:UInt32,msgType:MsgType_Objc,msgTime:UInt32,sessionID:String,senderID:String,msgContent:String,toUserID:String)->MTTMessageEntity{
        
        let newMsg:MTTMessageEntity = MTTMessageEntity.init()
        
        newMsg.msgID = msgID
        newMsg.msgType = msgType
        newMsg.msgTime = msgTime
        newMsg.sessionId = sessionID
        newMsg.senderId = senderID
        newMsg.toUserID = toUserID
        newMsg.msgContent = msgContent
        
        return newMsg
    }
    
    public class func initWith(content:String,module:HMChattingModule,msgContentType:DDMessageContentType)->MTTMessageEntity{
        let newMsg:MTTMessageEntity = MTTMessageEntity.init()
        
        if module.sessionEntity.sessionType == .sessionTypeGroup{
            newMsg.msgType = .msgTypeGroupText
        }else{
            newMsg.msgType = .msgTypeSingleText
        }
        newMsg.msgContent = content
        newMsg.msgContentType = msgContentType
        newMsg.msgID = MTTMessageEntity.getNewLocalMsgID()
        newMsg.sessionId = module.sessionEntity.sessionID
        newMsg.toUserID = module.sessionEntity.sessionID
        newMsg.senderId = HMCurrentUser().userId
        newMsg.state = .Sending
        newMsg.msgTime = UInt32(Date().timeIntervalSince1970)
        
        module.addShow(message: newMsg)
        module.updateSession(updateTime: TimeInterval(newMsg.msgTime))
        newMsg.updateToDB(compeletion: nil)
        return newMsg
    }
    
    public class func initWith(msgInfo:Im.BaseDefine.MsgInfo,sessionType:Im.BaseDefine.SessionType)->MTTMessageEntity{

        
        let newMsg:MTTMessageEntity = MTTMessageEntity.init()
        
        newMsg.msgID = msgInfo.msgId
        newMsg.msgTime =  msgInfo.createTime
        newMsg.msgType = MsgType_Objc.init(rawValue: msgInfo.msgType.rawValue) ?? .msgTypeSingleText
        newMsg.sessionType = sessionType
        newMsg.senderId = MTTUserEntity.localIDFrom(pbID: msgInfo.fromSessionId)
        if newMsg.sessionType == .sessionTypeSingle{
            newMsg.sessionId = MTTUserEntity.localIDFrom(pbID: msgInfo.fromSessionId)
        }else {
            newMsg.sessionId = MTTGroupEntity.localIDFrom(pbID: msgInfo.fromSessionId)
        }
        if newMsg.senderId == newMsg.sessionId{
            newMsg.toUserID =  HMCurrentUser().userId
        }else{
            newMsg.toUserID = newMsg.sessionId
        }
        if newMsg.isVoiceMessage {
            newMsg.msgContentType = .Voice
            
            if (msgInfo.msgData as NSData).length > 4 {
                self.saveDownloadVoice(data: msgInfo.msgData, compeletion: { (filepath , voiceLength) in
                    newMsg.msgContent = "[語音]"
                    
                    newMsg.voiceLength = Int(voiceLength)
                    newMsg.voiceHadPlayed = false
                    newMsg.voiceLocalPath = filepath
                })
            }else {
                newMsg.msgContent = "[語音存儲出錯]"
            }
        }else{
            if let tempStr = String.init(data: msgInfo.msgData, encoding: .utf8){
                newMsg.decode(content: tempStr)
            }else{
                debugPrint(self.classForCoder,"init with msgInfo、convert error")
            }
        }
        newMsg.updateToDB(compeletion: nil)
        return newMsg
        
    }
    

    
    public class func initWith(msgData:Im.Message.ImmsgData)->MTTMessageEntity{
        let newMsg:MTTMessageEntity = MTTMessageEntity.init()
        
        newMsg.msgID = msgData.msgId
        newMsg.msgTime = msgData.createTime
        newMsg.msgType = MsgType_Objc.init(rawValue: msgData.msgType.rawValue) ?? .msgTypeSingleText
        newMsg.sessionType = newMsg.isGroupMessage ? .sessionTypeGroup: .sessionTypeSingle
        if newMsg.sessionType == .sessionTypeSingle{
            newMsg.sessionId = MTTUserEntity.localIDFrom(pbID: msgData.fromUserId)
        }else {
            newMsg.sessionId = MTTGroupEntity.localIDFrom(pbID: msgData.toSessionId)
        }
        newMsg.senderId = MTTUserEntity.localIDFrom(pbID: msgData.fromUserId)
        
        if newMsg.senderId == newMsg.sessionId{
            newMsg.toUserID = HMCurrentUser().userId
        }else{
            newMsg.toUserID = newMsg.sessionId
        }
        if newMsg.isVoiceMessage {
            newMsg.msgContentType = .Voice
            
            if (msgData.msgData as NSData).length > 4 {
                self.saveDownloadVoice(data: msgData.msgData, compeletion: { (filepath , voiceLength) in
                    newMsg.msgContent = filepath
                    newMsg.voiceLocalPath = filepath
                    newMsg.voiceLength = Int(voiceLength)
                    newMsg.voiceHadPlayed = false
                })
            }else {
                newMsg.msgContent = "[語音存儲出錯]"
            }
        }else{
            
            if let tempStr = String.init(data: msgData.msgData, encoding: .utf8){
                newMsg.decode(content: tempStr)
            }else{
                debugPrint(self.classForCoder,"init with msgData、convert error")
            }
        }
        newMsg.updateToDB(compeletion: nil)
        return newMsg
    }
    
    private class func saveDownloadVoice(data:Data, compeletion: @escaping ((_ voiceFilePath:String,_ voiceLength:Int32) ->Void)){
        var filePath = ZQFileManager.shared.docPath(folder: "voice",fileName: "voice_\(TIMESTAMP()).spx")
        let tempData:NSData = data as NSData
        let realVoiceData:NSData = tempData.subdata(with: .init(location: 4, length: tempData.length - 4)) as NSData
        if realVoiceData.write(toFile: filePath, atomically: true){
        }else{
            filePath = "語音存儲出錯"
        }
        
        var ch1:Int32 = 0
        var ch2:Int32 = 0
        var ch3:Int32 = 0
        var ch4:Int32 = 0
        tempData.getBytes(&ch1, range: NSRange.init(location: 0, length: 1))
        tempData.getBytes(&ch2, range: NSRange.init(location: 1, length: 1))
        tempData.getBytes(&ch3, range: NSRange.init(location: 2, length: 1))
        tempData.getBytes(&ch4, range: NSRange.init(location: 3, length: 1))
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
    
    public func getUploadVoiceData()->Data{
        
        let localPath = self.voiceLocalPath
        let length:Int = self.voiceLength

        if FileManager.default.fileExists(atPath: localPath){
            do {
                let voicedata = try  NSData.init(contentsOfFile: localPath) as Data
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
    }
}

let HM_Local_message_beginID:UInt32 = 1000000

extension MTTMessageEntity {
    func updateToDB(compeletion:((Bool)->Void)?){
        self.dbUpdate(completion: nil)
    }
    
    /// 生成本地新消息ID
    ///
    /// - Returns: 新ID
    class func getNewLocalMsgID()->UInt32{
        let key :String = "msg_id"
        var newMsgID:UInt32 = UInt32(UserDefaults.standard.integer(forKey: key))
        if newMsgID == 0 {
            newMsgID = HM_Local_message_beginID
        }else{
            newMsgID += 1
        }
        UserDefaults.standard.setValue(newMsgID, forKey: key )
        UserDefaults.standard.synchronize()
        
        return newMsgID
    }
}

extension String {
    
    func decrypt()->String {

        let indata = self.cString(using: .utf8)
        var pout:UnsafeMutablePointer<Int8>?
        var outLen:UnsafeMutablePointer<UInt32>?
        let inLen:Int32 = Int32(strlen(self))
        
        DecryptMsg(indata, inLen, &pout, &outLen)
        
        if pout != nil {
            let deResult = String.init(cString: pout!)
            return deResult
        }else{
            return ""
        }
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

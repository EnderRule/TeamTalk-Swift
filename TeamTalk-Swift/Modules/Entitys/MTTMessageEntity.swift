//
//  MTTMessageEntity.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

@objc public  enum DDMessageContentType:Int {
    case Text      = 0
    case Image     = 1
    case Voice     = 2
    case Emotion        = 3
    case Audio          = 100
    case GroupAudio     = 101
}

@objc public  enum DDMessageState:Int{
    case Sending = 0
    case SendFailure = 1
    case SendSuccess = 2
    case UnRead = 3
    case Readed = 4
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
public class MTTMessageEntity: MTTBaseEntity,HMDBModelDelegate {
    
    public func dbFields() -> [String] {
        return ["msgID","msgTime","seqNo",
                "sessionId","senderId","toUserID",
                "msgContent","attach","extraInfo",
                "msgContentTypeInt","sessionTypeInt","msgTypeInt","stateInt"]
    }
    public func dbPrimaryKeys() -> [String] {
        return ["msgID","sessionId"]
    }
    
    public var msgID:UInt32 = 0
    public var msgTime:UInt32 = 0
    public var seqNo:UInt32 = 0
    public var sessionId:String = ""
    public var senderId:String = ""
    public var toUserID:String = ""
    public var msgContent:String = ""
    public var attach:String = ""
    public var extraInfo:[String:Any] = [:]

    var msgContentTypeInt:Int16 = Int16(DDMessageContentType.Text.rawValue)
    var sessionTypeInt:Int16 = Int16(SessionType_Objc.sessionTypeSingle.rawValue)
    var msgTypeInt:Int16 = Int16(MsgType_Objc.msgTypeSingleText.rawValue)
    var stateInt:Int16 = Int16(DDMessageState.SendSuccess.rawValue)

    public var msgContentType:DDMessageContentType{
        set{
            self.msgContentTypeInt = Int16(newValue.rawValue)
        }
        get{
            return DDMessageContentType.init(rawValue: Int(self.msgContentTypeInt))!
        }
        
    }
    
    public var sessionType:Im.BaseDefine.SessionType{
        set{
            self.sessionTypeInt = Int16(newValue.rawValue)
        }
        get{
            return self.sessionTypeInt == 1 ? Im.BaseDefine.SessionType.sessionTypeSingle : Im.BaseDefine.SessionType.sessionTypeGroup
        }
    }
    public var msgType:MsgType_Objc{
        set{
            self.msgTypeInt = Int16(newValue.rawValue)
        }
        get{
            return MsgType_Objc.init(rawValue: Int32(self.msgTypeInt))!
        }
        
    }
    public var state:DDMessageState{
        set{
            self.stateInt = Int16(newValue.rawValue)
        }
        get{
            return DDMessageState.init(rawValue: Int(self.stateInt))!
        }
        
    }
 
    public var isGroupMessage:Bool {
        get{
            return ( self.msgType == .msgTypeGroupAudio || self.msgType == .msgTypeGroupText)
        }
    }
    public var isVoiceMessage:Bool {
        get {
            return ( self.msgType == .msgTypeGroupAudio || self.msgType == .msgTypeSingleAudio || self.msgContentType == .Voice)
        }
    }
    public var isGroupVoiceMessage:Bool {
        get {
            return self.msgType == .msgTypeGroupAudio
        }
    }
    public var isImageMessage:Bool {
        return self.msgContentType == .Image
    }
    public var isSendBySelf:Bool {
       return  self.senderId == HMLoginManager.shared.currentUser.userId
    }
    public var isEmotionMsg:Bool{
        return   self.msgContentType == .Emotion
    }
    public var isValide:Bool {
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
    
}

public extension MTTMessageEntity {
    //聲音消息
    static let kVoiceHadPlayed:String             = "voiceHadPlayed"
    static let kVoiceLength:String                = "voiceLength"
    static let kVoiceLocalPath:String             = "voiceLocalPath"
    public var voiceHadPlayed:Bool{
        get{
            return self.extraInfo[MTTMessageEntity.kVoiceHadPlayed] as? Bool ?? false
        }
        set{
            self.extraInfo.updateValue(newValue, forKey: MTTMessageEntity.kVoiceHadPlayed)
        }
    }
    public var voiceLocalPath:String{
        get{
            return (self.extraInfo[MTTMessageEntity.kVoiceLocalPath] as? String ?? "").safeLocalPath()
        }
        set{
            self.extraInfo.updateValue(newValue, forKey: MTTMessageEntity.kVoiceLocalPath)
        }
    }
    public var voiceLength:Int{
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
    public var imageLocalPath:String{
        get{
            return (self.extraInfo[MTTMessageEntity.kImageLocalPath] as? String ?? "").safeLocalPath()
        }
        set{
            self.extraInfo.updateValue(newValue, forKey: MTTMessageEntity.kImageLocalPath)
        }
    }
    public var imageUrl:String{
        get{
            return self.extraInfo[MTTMessageEntity.kImageUrl] as? String ?? ""
        }
        set{
            self.extraInfo.updateValue(newValue, forKey: MTTMessageEntity.kImageUrl)
        }
    }
    public var imageScale:CGFloat{
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
    public var emojiText:String{
        get{
            return self.extraInfo[MTTMessageEntity.kEmojiText] as? String ?? ""
        }
        set{
            self.extraInfo.updateValue(newValue, forKey: MTTMessageEntity.kEmojiText)
        }
    }
    public var emojiCategory:String{
        get{
            return self.extraInfo[MTTMessageEntity.kEmojiCategory] as? String ?? ""
        }
        set{
            self.extraInfo.updateValue(newValue, forKey: MTTMessageEntity.kEmojiCategory)
        }
    }
    public var emojiName:String{
        get{
            return self.extraInfo[MTTMessageEntity.kEmojiName] as? String ?? ""
        }
        set{
            self.extraInfo.updateValue(newValue, forKey: MTTMessageEntity.kEmojiName)
        }
    }
    
}

public extension MTTMessageEntity {
    
    static let msgKey:String = "6f1cd98c5655da86d60a73effae355eb"
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
    
     func decode(content:String){
        
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
    
     func encodeContent()->String{
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

        HMPrint("MTTMessageEntity encode ",dic as NSDictionary)
        
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
        newMsg.senderId = HMLoginManager.shared.currentUser.userId
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
            newMsg.toUserID =  HMLoginManager.shared.currentUser.userId
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
                HMPrint(self.classForCoder,"init with msgInfo、convert error")
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
            newMsg.toUserID = HMLoginManager.shared.currentUser.userId
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
                HMPrint(self.classForCoder,"init with msgData、convert error")
            }
        }
        newMsg.updateToDB(compeletion: nil)
        return newMsg
    }
    
    private class func saveDownloadVoice(data:Data, compeletion: @escaping ((_ voiceFilePath:String,_ voiceLength:Int32) ->Void)){
        var filePath = self.newVoicePath()
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
            HMPrint(self.classForCoder,"init with msgData 、parse voice EOFException")
        }
        let voiceLength:Int32 = ((ch1 << 24) + (ch2 << 16) + (ch3 << 8) + (ch4 << 0))
        
        compeletion(filePath,voiceLength)
    }
    
    private class func newVoicePath()->String{
        
        let folderName = "voice"
        let fileName = "voice_\(TIMESTAMP()).spx"
        
        let docpath = NSSearchPathForDirectoriesInDomains( .documentDirectory,  .userDomainMask, true).first ?? ""
        
        let folderPath = (docpath as NSString).appendingPathComponent(folderName)
        if !FileManager.default.fileExists(atPath: folderPath){
            do {
                try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: false , attributes: nil)
            }catch{
                HMPrint("fail to create dir :\(folderPath)  error:\(error.localizedDescription)")
            }
        }
        let filePath = (folderPath as NSString).appendingPathComponent(fileName)
        if !FileManager.default.fileExists(atPath: filePath){
            FileManager.default.createFile(atPath: filePath, contents: nil , attributes: nil)
        }
        return filePath
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

public extension MTTMessageEntity {
    public func updateToDB(compeletion:((Bool)->Void)?){
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
    
    ///data末尾的非<00> 部分指定了data的有效长度，之间的<00>为填充的
    func encrypt()->String{
        if self.characters.count <= 0{ return ""}
        

        
        let blockSize:Int = 16
        let handleData:NSMutableData = NSMutableData.init(data:   self.data(using: .utf8) ?? Data() )
        
        let validedDataLenght:Int = handleData.length
        
        let lenghtasData :NSData = DataEncode.hexString(toData: DataEncode.getHexByDecimal(validedDataLenght)) as NSData
        
        let paddingLenght = blockSize - (validedDataLenght ) % blockSize - lenghtasData.length
        
        
        let paddingData = DataEncode.hexString(toData: "00")
        for _ in 1...paddingLenght{
            handleData.append(paddingData)
        }
        handleData.append(lenghtasData as Data)
        
//        debugPrint("message encrypt \(validedDataLenght) \(paddingLenght) \(lenghtasData) \(handleData) \(self)")
        
        let returnData = DataEncode.handle(handleData as Data, algorithem: DEAlgrithmAES128, encryptOrDecrypt: DEActionEncrypt, key: MTTMessageEntity.msgKey)
        
    
        let result = GTMBase64.string(byEncoding: returnData) ?? ""
        return result
        
    }
    
    func decrypt()->String{
        if self.characters.count <= 0{ return ""}
        
        let handleData:NSMutableData = NSMutableData.init(data:GTMBase64.decode( self.data(using: .utf8)!))
        
        let decodeData = DataEncode.handle(handleData as Data, algorithem: DEAlgrithmAES128, encryptOrDecrypt: DEActionDecrypt, key: MTTMessageEntity.msgKey)
        
        let tempData = NSData.init(data: decodeData)
        
        let paddingData = DataEncode.hexString(toData: "00")
        var valideDataLenghtInData:Int = 0
        for index in (0...tempData.length-1).reversed(){
            let subdata:NSData = tempData.subdata(with: NSRange.init(location: index, length: 1)) as NSData
            if !subdata.isEqual(to: paddingData){
                valideDataLenghtInData += 1
            }else{
                break
            }
        }
        
        let valideLenghtasData = tempData.subdata(with: NSRange.init(location: tempData.length - valideDataLenghtInData, length: valideDataLenghtInData))
        
        var valideLenght = DataEncode.getDecimalByHex( DataEncode.data(toHexString: valideLenghtasData) )
        
        
        if valideLenght > tempData.length {
            valideLenght = tempData.length
        }
        
        let finalData = tempData.subdata(with: NSRange.init(location: 0, length: valideLenght))
        
        let result = String.init(data: finalData, encoding: .utf8) ?? ""
        
//        debugPrint("message decrypt \(valideLenght) \(tempData as NSData) \(valideLenghtasData as NSData) result:\(result)")

        return result
    }
    
//    func decrypt()->String {

//        let indata = self.cString(using: .utf8)
//        var pout:UnsafeMutablePointer<Int8>?
//        var outLen:UnsafeMutablePointer<UInt32>?
//        let inLen:Int32 = Int32(strlen(self))
//        
        
//        DecryptMsg(indata, inLen, &pout, &outLen)
        
//        if pout != nil {
//            let deResult = String.init(cString: pout!)
//            return deResult
//        }else{
//            return ""
//        }
//    }
    
//    func encrypt()->String {
//        let tempStr = self
//        let indata = tempStr.cString(using: .utf8)
//        var pout:UnsafeMutablePointer<Int8>?
//        var outLen:UnsafeMutablePointer<UInt32>?
//        let inLen:Int32 = Int32(strlen(tempStr))
//        
////        EncryptMsg(indata, inLen, &pout, &outLen)
//        
//        if pout != nil {
//            let enResult = String.init(cString: pout!)
//            return enResult
//        }
//        return ""
//    }
}


public class MTTMsgReadState:NSObject,HMDBModelDelegate{
    
    public func dbFields() -> [String] {
        return ["msgID","stateInt","sessionID"]
    }
    
    public func dbPrimaryKeys() -> [String] {
        return ["msgID","sessionID"]
    }
    
    public var sessionID:String = ""
    public var msgID:UInt32 = 0
    public var stateInt:Int = 2
    
    public var state:DDMessageState{
        set{
            self.stateInt = Int(newValue.rawValue)
        }
        get{
            return DDMessageState.init(rawValue: Int(self.stateInt)) ?? .SendSuccess
        }
        
    }
    
    public convenience init(msgID:UInt32,sessionID:String,state:DDMessageState){
        self.init()
        self.msgID = msgID
        self.state = state
        self.sessionID = sessionID
    }
    
    ///存
    public class func save(message:MTTMessageEntity,state:DDMessageState){
        self.save(msgID: message.msgID, sessionID: message.sessionId, state: state)
    }
    public class func save(msgID:UInt32,sessionID:String,state:DDMessageState){
        let obj = MTTMsgReadState.init(msgID: msgID,sessionID:sessionID, state: state)
        obj.dbSave(completion: nil)
    }
    
    ///查
    public class func stateFor(message:MTTMessageEntity)->DDMessageState{
        return self.stateFor(msgID: message.msgID, sessionID: message.sessionId)
    }
    public class func stateFor(msgID:UInt32,sessionID:String)->DDMessageState{
        var state:DDMessageState = .SendSuccess
        DispatchQueue.global().sync {
            
            MTTMsgReadState.dbQuery(whereStr: "msgID = \(msgID) and sessionID = ?", orderFields: nil , offset: 0, limit: 1, args: [sessionID]) { (obj , eror ) in
                if let readstate  = (obj as?[MTTMsgReadState] ?? []).first{
                    state = readstate.state
                }
            }
        }
        return state
    }
    
}

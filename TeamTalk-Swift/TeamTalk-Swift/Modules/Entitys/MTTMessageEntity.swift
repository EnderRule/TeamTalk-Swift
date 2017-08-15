//
//  MTTMessageEntity.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

enum DDMessageContentType:Int {
    case Text      = 0
    case Image     = 1
    case Voice     = 2
    case Emotion        = 3
    case Audio          = 100
    case GroupAudio     = 101
}

enum DDMessageState:Int{
    case Sending = 0
    case SendFailure = 1
    case SendSuccess = 2
}

class MTTMessageEntity: NSObject {
    var msgID:Int = 0
    var msgType:Im.BaseDefine.MsgType = .msgTypeSingleText
    var msgTime:TimeInterval = 0
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
    
    
    public convenience init(msgID:Int,msgType:Im.BaseDefine.MsgType,msgTime:TimeInterval,sessionID:String,senderID:String,msgContent:String,toUserID:String){
        self.init()
        
        self.msgID = msgID
        self.msgType = msgType
        self.msgTime = msgTime
        self.sessionId = sessionID
        self.senderId = senderID
        self.toUserID = toUserID
        self.msgContent = msgContent
        
    }
    
    public convenience init(content:String,module:Any,msgContentType:DDMessageContentType){
        self.init()
        
        self.msgContentType = msgContentType
        //Fixme: add a ChattingModule here
        
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
        //Fixme: check theruntime user here
//        self.senderId == TheRunTime.user.objID
        return false
    }
    
}

extension MTTMessageEntity {
    public convenience init(msgInfo:Im.BaseDefine.MsgInfo,sessionType:Im.BaseDefine.SessionType){
        self.init()
        
        self.msgTime = TimeInterval( msgInfo.createTime)
        //Fixme: upate values here

    }
    
    public convenience init(msgData:Im.Message.ImmsgData){
        self.init()
        
        self.msgTime = TimeInterval( msgData.createTime)
        //Fixme: upate values here

    }
}


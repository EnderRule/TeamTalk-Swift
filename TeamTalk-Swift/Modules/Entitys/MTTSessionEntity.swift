//
//  MTTSessionEntity.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

@objc public enum SessionType_Objc:Int32 {
    ///单个用户会话
    case sessionTypeSingle = 1
    
    ///群会话
    case sessionTypeGroup = 2
    public func toString() -> String {
        switch self {
        case .sessionTypeSingle: return "SESSION_TYPE_SINGLE"
        case .sessionTypeGroup: return "SESSION_TYPE_GROUP"
        }
    }
    public static func fromString(_ str:String) throws -> SessionType_Objc {
        switch str {
        case "SESSION_TYPE_SINGLE":    return .sessionTypeSingle
        case "SESSION_TYPE_GROUP":    return .sessionTypeGroup
        default: return .sessionTypeSingle
        }
    }
    public var debugDescription:String { return getDescription() }
    public var description:String { return getDescription() }
    private func getDescription() -> String {
        switch self {
        case .sessionTypeSingle: return ".sessionTypeSingle"
        case .sessionTypeGroup: return ".sessionTypeGroup"
        }
    }
    public var hashValue:Int {
        return self.rawValue.hashValue
    }
    public static func ==(lhs:SessionType_Objc, rhs:SessionType_Objc) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}



//ID text UNIQUE,
//avatar text,
//type integer,
//name text,
//updated real,
//isshield integer,
//users Text ,
//unreadCount integer,
//lasMsg text ,
//lastMsgId integer


public class MTTSessionEntity: NSObject,HMDBModelDelegate {
    
    public func dbFields() -> [String] {
        return ["sessionID","avatar","s_name","lastMsg","lastMsgID","sessionTypeInt","timeInterval","unReadMsgCount","isShield","isFixedTop"]
    }
    
    public func dbPrimaryKeys() -> [String] {
        return ["sessionID"]
    }
    
    public var sessionID:String = ""
    public var sessionIntID:UInt32{
        return MTTBaseEntity.pbIDFrom(localID: self.sessionID)
    }
    
    
    var sessionTypeInt:Int32 = 0
    public var sessionType:SessionType_Objc{
        get{
            return SessionType_Objc.init(rawValue: sessionTypeInt) ?? SessionType_Objc.sessionTypeSingle
        }
        set{
            sessionTypeInt = newValue.rawValue
        }
    }
    
    private var s_name:String = ""
    public var name:String {
        get{
            if s_name.length <= 0 {
                if self.sessionType == .sessionTypeSingle {
                    if let user:MTTUserEntity = HMUsersManager.shared.userFor(ID: self.sessionID){
                        if user.nickName.length > 0 {
                            self.s_name = user.nickName
                        }else{
                            self.s_name = user.name
                        }
                    }
                }else {
                    if let group = HMGroupsManager.shared.groupFor(ID: self.sessionID){
                        self.s_name = group.name
                        
                    }
                }
            }
            return s_name
        }
        set{
            s_name = newValue
        }
    }
    public var unReadMsgCount:Int = 0
    private var  s_timeInterval:TimeInterval = 0
    public var timeInterval:TimeInterval {
        get{
            if s_timeInterval == 0 {
                if self.sessionType == .sessionTypeSingle, let user:MTTUserEntity = HMUsersManager.shared.userFor(ID: self.sessionID){
                    self.s_timeInterval = TimeInterval( user.lastUpdateTime)
                }
                if self.sessionType == .sessionTypeGroup, let group:MTTGroupEntity = HMGroupsManager.shared.groupFor(ID: self.sessionID){
                    self.s_timeInterval = TimeInterval( group.lastUpdateTime)
                }
            }
            return s_timeInterval
        }
        set{
            s_timeInterval = newValue
        }
    }
    
    public var isShield:Bool = false
    public var isFixedTop:Bool = false
    
    public var lastMsg:String = ""
    public var lastMsgID:UInt32 = 0
    public var avatar:String = ""
    
    public var lastMessage:MTTMessageEntity?
    
    public var sessionUsers:[String] {
        get{
            if self.sessionType == .sessionTypeGroup{
                if let group = HMGroupsManager.shared.groupFor(ID: self.sessionID){
                    return group.groupUserIds
                }
                return []
            }else{
                return []
            }
        }
    }
    
    public var isGroupSession:Bool {
        get{
            return self.sessionType == .sessionTypeGroup
        }
    }
    
    public convenience init(sessionID:String,sessionName:String?,type:SessionType_Objc){
        self.init()
        
        self.sessionID = sessionID
        self.sessionType = type
        
        self.name = sessionName ?? ""
        self.lastMsg = ""
        self.lastMsgID = 0
        self.timeInterval = Date().timeIntervalSince1970
    } 
}


public extension MTTSessionEntity {
    public convenience init(user:MTTUserEntity){
        self.init(sessionID: user.objID, sessionName: user.name, type: .sessionTypeSingle)
    }
    
    public convenience init(group:MTTGroupEntity){
        self.init(sessionID: group.objID, sessionName: group.name, type: .sessionTypeGroup)
    }
    
    public convenience init(unreadInfo:Im.BaseDefine.UnreadInfo){
        self.init()
        
        let sessionType = unreadInfo.sessionType
        self.sessionID = MTTSessionEntity.sessionIDFrom(pbID: unreadInfo.sessionId, BaseSessionType: sessionType)
        if sessionType == .sessionTypeGroup{
            self.sessionType = .sessionTypeGroup
        }else{
            self.sessionType = .sessionTypeSingle
        }
        self.unReadMsgCount = Int(unreadInfo.unreadCnt)
        
        self.lastMsgID = UInt32(unreadInfo.latestMsgId)
        
        if let encryMsg = String.init(data: unreadInfo.latestMsgData, encoding: .utf8){
            self.lastMsg = MTTMessageEntity.pb_decode(content: encryMsg)
        }
    }
    public convenience init(sessionInfo:Im.BaseDefine.ContactSessionInfo){
        self.init()
        
        self.sessionType = SessionType_Objc(rawValue:  sessionInfo.sessionType.rawValue) ?? .sessionTypeSingle
        
        if sessionType == .sessionTypeSingle {
            self.sessionID = MTTUserEntity.localIDFrom(pbID: sessionInfo.sessionId)
        }else{
            self.sessionID = MTTGroupEntity.localIDFrom(pbID: sessionInfo.sessionId)
        }
        
        self.lastMsgID = UInt32( sessionInfo.latestMsgId)
        self.timeInterval = TimeInterval(sessionInfo.updatedTime)
        
        if let encryMsg = String.init(data: sessionInfo.latestMsgData, encoding: .utf8){
            self.lastMsg = MTTMessageEntity.pb_decode(content: encryMsg)
        }
    }
    
    
    public class func sessionIDFrom(pbID:UInt32,sessionType:SessionType_Objc) -> String{
        if sessionType == .sessionTypeSingle{
            return MTTUserEntity.localIDFrom(pbID: pbID)
        }else{
            return MTTGroupEntity.localIDFrom(pbID: pbID)
        }
    } 
    public class func sessionIDFrom(pbID:UInt32,BaseSessionType:Im.BaseDefine.SessionType) -> String{
        if BaseSessionType == .sessionTypeSingle{
            return MTTUserEntity.localIDFrom(pbID: pbID)
        }else{
            return MTTGroupEntity.localIDFrom(pbID: pbID)
        }
    }
}

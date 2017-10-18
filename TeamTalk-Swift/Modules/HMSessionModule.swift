//
//  HMSessionModule.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/10/16.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

@objc public  enum HMSessionAction:Int {
    case add = 0
    case refresh = 1
    case delete = 2
}

@objc public protocol HMSessionModuleDelegate:NSObjectProtocol{
    @objc func  sessionUpdate(session:MTTSessionEntity,action:HMSessionAction)
}


public class HMSessionModule: NSObject {
    public static let shared:HMSessionModule = HMSessionModule()
    
    
    private var currentSessions:[String:MTTSessionEntity] = [:]
    
    public var delegate:HMSessionModuleDelegate?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self , selector: #selector(self.sendMessageSuccess(notification:)), name: HMNotification.sendMessageSucceed.notificationName() , object: nil)
        NotificationCenter.default.addObserver(self , selector: #selector(self.receiveMessage(notification:)), name: HMNotification.receiveMessage.notificationName() , object: nil)
  
    }
    
    
    public func getAllSessions()->[MTTSessionEntity]{
        var temp:[MTTSessionEntity] = []
        for obj in currentSessions.values{
            temp.append(obj)
        }
        return temp
    }
    
    public func add(sessions:[MTTSessionEntity]){
        for session in sessions{
            currentSessions.updateValue(session, forKey: session.sessionID)
        }
    }
    
    public func sessionFor(sessionID:String)->MTTSessionEntity?{
        return currentSessions[sessionID]
    }
    
    public func getRecentSessionFromServer(completion:((Int)->Void)?){
        let allsessions = self.getAllSessions()
        let maxTime = self.getMaxTime(sessions: allsessions)
        
        let api = GetRecentSessionAPI.init(latestUpdateTime: UInt32(maxTime))
        api.request(withParameters: [:]) { (responde , error ) in
            let sessions:[MTTSessionEntity] = responde as? [MTTSessionEntity] ?? []
            for session in sessions{
                
                session.dbSave(completion: nil )
            }
            self.add(sessions: sessions)
            
            self.getHadUnReadMsg(completion: nil )
            
            completion?(sessions.count)
        }
    }
    
    
    
    public func removeSessionFromServer(session:MTTSessionEntity){
        session.dbDelete(completion: nil )
        
        let api = RemoveSessionAPI.init(ID: session.sessionIntID, type: session.sessionType)
        api.request(withParameters: [:]) { (obj , error ) in
            
        }
    }
    
    public func clearSessions(){
        currentSessions.removeAll()
    }
    
    public func loadLocalSession(completion:((Bool)->Void)?){
        MTTSessionEntity.dbQuery(whereStr: nil , orderFields: "timeInterval asc", offset: 0, limit: 0, args: []) { (sessions , error ) in
            for obj in sessions{
                if let session = obj as? MTTSessionEntity {
                    self.add(sessions: [session])
                }
            }
            completion?(error != nil)
        }
    }
    
    public func getAllUnreadMsgCount()->Int{
        let allsessions = self.getAllSessions()
        var unreadCount:Int = 0
        
        for obj in allsessions{
            var tempUnread = obj.unReadMsgCount
            DispatchQueue.global().sync {
                if obj.isGroupSession{
                    if let group = HMGroupsManager.shared.groupFor(ID: obj.sessionID){
                        if group.isShield{
                            tempUnread = 0
                        }
                    }
                }
            }
            unreadCount += tempUnread
        }
        return unreadCount
    }
    
    public func getFixedTopSessions()->[MTTSessionEntity]{
        
        var temp:[MTTSessionEntity] = []
        for obj in currentSessions.values{
            if obj.isFixedTop{
                temp.append(obj)
            }
        }
        return temp
    }
    
    private func getMaxTime(sessions:[MTTSessionEntity])->TimeInterval{
        var maxTime:TimeInterval = 0.0
        
        for session in sessions{
            if session.timeInterval > maxTime{
                maxTime = session.timeInterval
            }
        }
        return maxTime
    }
    
    @objc private func sendMessageSuccess(notification:NSNotification){
        if let message = notification.object as? MTTMessageEntity{
            var sessionType:SessionType_Objc = .sessionTypeSingle
            if message.isGroupMessage{
                sessionType = .sessionTypeGroup
            }
            
            if let session = self.sessionFor(sessionID: message.sessionId){
                session.lastMsgID = message.msgID
                session.lastMsg = message.msgContent
                session.timeInterval = TimeInterval(message.msgTime)
                
                session.dbUpdate(completion: nil)
                
                self.delegate?.sessionUpdate(session: session, action: .refresh)
            }else{
                let newsession = MTTSessionEntity.init(sessionID: message.sessionId, sessionName: nil , type: sessionType)
                newsession.lastMsg = message.msgContent
                newsession.lastMsgID = message.msgID
                newsession.timeInterval = TimeInterval(message.msgTime)
                newsession.dbSave(completion: nil )
                self.add(sessions: [newsession])
                
                self.delegate?.sessionUpdate(session: newsession, action: .add)
            }
            
        }
    }
    
    @objc private func receiveMessage(notification:NSNotification){
        if let message = notification.object as? MTTMessageEntity{
            var sessionType:SessionType_Objc = .sessionTypeSingle
            if message.isGroupMessage{
                sessionType = .sessionTypeGroup
            }
            
            if let session = self.sessionFor(sessionID: message.sessionId){
                session.lastMsgID = message.msgID
                session.lastMsg = message.msgContent
                session.timeInterval = TimeInterval(message.msgTime)
                session.lastMessage = message
                
                if let chattingVC:HMChattingViewController = UIApplication.shared.keyWindow?.rootViewController?.topVC() as? HMChattingViewController{
                    if chattingVC.chattingModule.sessionEntity.sessionID != message.sessionId {
                        session.unReadMsgCount += 1
                    }
                }else{
                    session.unReadMsgCount += 1
                }
                
                session.dbUpdate(completion: nil)
                
                self.delegate?.sessionUpdate(session: session, action: .refresh)
            }else{
                let newsession = MTTSessionEntity.init(sessionID: message.sessionId, sessionName: nil , type: sessionType)
                newsession.lastMsg = message.msgContent
                newsession.lastMsgID = message.msgID
                newsession.timeInterval = TimeInterval(message.msgTime)
                newsession.lastMessage = message
                newsession.unReadMsgCount = 1
                
                newsession.dbSave(completion: nil )
                self.add(sessions: [newsession])
                
                self.delegate?.sessionUpdate(session: newsession, action: .add)
            }
        
        }
    }
    
//    @objc private func receiveMessageReadACK(notification:NSNotification){
//        if let message = notification.object as? MTTMessageEntity {
//            if let session = self.sessionFor(sessionID: message.sessionId){
//                session.unReadMsgCount -= 1
//                session.dbSave(completion: nil )
//                
//                self.delegate?.sessionUpdate(session: session, action: .refresh)
//            }
//        }
//    }
    
    public func cleanMsgFromNotific(messageID:UInt32,sessionID:String,sessionType:SessionType_Objc)
    {
        if sessionID != HMLoginManager.shared.currentUser.userId {
            if let session = self.sessionFor(sessionID: sessionID){
            
                let readCount = messageID - session.lastMsgID
                
                if readCount == 0 {
                    self.delegate?.sessionUpdate(session: session , action: .add)
                    session.unReadMsgCount = 0
                    session.dbSave(completion: nil )
                }else if readCount > 0 {
                    self.delegate?.sessionUpdate(session: session, action: .add)
                    session.unReadMsgCount = Int(readCount)
                    session.dbSave(completion: nil )
                }
                HMMessageManager.shared.sendReceiveACK(msgID: messageID, sessionID: sessionID, sessionType: sessionType)
            }
        }
    }
    
    private func  getHadUnReadMsg(completion:((Int)->Void)?){
        let api = GetUnreadMessagesAPI.init()
        api.request(withParameters: [:]) { (response, error ) in
            let dic = response as? [String:Any] ?? [:]
            let totalUnread = dic["m_total_cnt"] as? Int ?? 0
            let sessions:[MTTSessionEntity] = dic["sessions"] as? [MTTSessionEntity] ?? []
            
            for session in sessions {
                if let  localsession = self.sessionFor(sessionID: session.sessionID){
                    localsession.lastMsg = session.lastMsg
                    localsession.timeInterval = session.timeInterval
                    localsession.lastMsgID = session.lastMsgID
                    localsession.unReadMsgCount = session.unReadMsgCount
                    localsession.dbSave(completion: nil )
                    self.delegate?.sessionUpdate(session: localsession, action: .refresh)
                    
                    HMPrint("get Had UnRead Msg:\(session.sessionID) \(session.name) \(session.unReadMsgCount)")
                }
            }
            completion?(totalUnread)
        }
    }
}

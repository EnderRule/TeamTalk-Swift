//
//  HMSessionModule.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/10/16.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

@objc enum HMSessionAction:Int {
    case add = 0
    case refresh = 1
    case delete = 2
}

@objc protocol HMSessionModuleDelegate:NSObjectProtocol{
    @objc func  sessionUpdate(session:MTTSessionEntity,action:HMSessionAction)
}


class HMSessionModule: NSObject {
    static let shared:HMSessionModule = HMSessionModule()
    
    
    private var currentSessions:[String:MTTSessionEntity] = [:]
    
    var delegate:HMSessionModuleDelegate?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self , selector: #selector(self.sendMessageSuccess(notification:)), name: HMNotification.sendMessageSucceed.notificationName() , object: nil)
        NotificationCenter.default.addObserver(self , selector: #selector(self.receiveMessageReadACK(notification:)), name: HMNotification.receiveMessageReadACK.notificationName() , object: nil)
        NotificationCenter.default.addObserver(self , selector: #selector(self.receiveMessage(notification:)), name: HMNotification.receiveMessage.notificationName() , object: nil)

        let api = MsgReadNotifyAPI.init()
        
        api.registerAPI { (obj , error ) in
            let dic = obj as! [String:Any]
            if dic.count > 0 {
                let fromID = dic["from_id"] as? UInt32 ?? 0
                let type = dic["type"] as? Int ?? 1
                let msgID = dic["msgId"] as? UInt32 ?? 0
                
                let sessionType:SessionType_Objc = type == 1 ? .sessionTypeSingle:.sessionTypeGroup
                let sessionID:String = sessionType == .sessionTypeSingle ? MTTUserEntity.localIDFrom(pbID: fromID) : MTTGroupEntity.localIDFrom(pbID: fromID)
                
                self.cleanMsgFromNotific(messageID: msgID, sessionID: sessionID, sessionType: sessionType)
            }
        }
        
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
        let maxTime = (allsessions as NSArray).value(forKeyPath: "@max.s_timeInterval") as? TimeInterval ?? 0
        
        let api = GetRecentSessionAPI.init(latestUpdateTime: UInt32(maxTime))
        api.request(withParameters: [:]) { (responde , error ) in
            let sessions:[MTTSessionEntity] = responde as? [MTTSessionEntity] ?? []
            for session in sessions{
                session.dbSave(completion: nil )
                self.add(sessions: [session])
            }
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
        MTTSessionEntity.dbQuery(whereStr: nil , orderFields: "s_timeInterval asc", offset: 0, limit: 0, args: []) { (sessions , error ) in
            for obj in sessions{
                if let session = obj as? MTTSessionEntity {
                    self.add(sessions: [session])
                }
            }
            completion?(error != nil)
        }
    }
    
    public func getAllUnreadMsgCount()->Int{
        
        return 0
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
    
    @objc private func sendMessageSuccess(notification:NSNotification){

    }
    
    @objc private func receiveMessage(notification:NSNotification){
        
    }
    
    @objc private func receiveMessageReadACK(notification:NSNotification){
        if let message = notification.object as? MTTMessageEntity {
            if let session = self.sessionFor(sessionID: message.sessionId){
                session.unReadMsgCount -= 1
                session.dbSave(completion: nil )
                
                self.delegate?.sessionUpdate(session: session, action: .refresh)
            }
        }
    }
    
    private func cleanMsgFromNotific(messageID:UInt32,sessionID:String,sessionType:SessionType_Objc)
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
                }
            }
            completion?(totalUnread)
        }
    }
}

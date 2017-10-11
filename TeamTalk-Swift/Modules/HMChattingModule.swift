//
//  HMChattingModule.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/9/8.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

let HM_Message_Page_Item_Count:Int = 20


let showPromtGap:UInt32 = 300   //间隔多久需要显示时间提示标签

typealias HMLoadMoreHistoryMessageCompletion = ((Int,NSError?)->Void)  // callback : addcount and error

class HMChattingModule: NSObject {

    var sessionEntity:MTTSessionEntity!{
        didSet{
            showingMessages.removeAll()
            msgIDs.removeAll()
            lastestMsgDate = 0
            earliestMsgDate = 0
        }
    }
    
    var msgIDs:[UInt32] = []
    
    var showingMessages:[Any] = []
    
    private var lastestMsgDate:UInt32 = 0
    private var earliestMsgDate:UInt32 = 0
    
    public convenience init(session:MTTSessionEntity) {
        self.init()
        
        self.sessionEntity = session
    }

    
    func loadMoreHistory(completion:@escaping HMLoadMoreHistoryMessageCompletion){
        let offset = self.p_getMessageCount()
        
        let predicate:NSPredicate = NSPredicate.init(format: "sessionId = \(self.sessionEntity.sessionID)", argumentArray: nil)
        MTTMessageEntity.db_query(predicate: predicate, sortBy: "msgTime", sortAscending: false , offset: offset, limitCount: HM_Message_Page_Item_Count, success: { (messages ) in
            
            var tempMessages:[MTTMessageEntity] = []
            for obj in messages{
                if let message = obj as? MTTMessageEntity{
                    tempMessages.append(message)
                }
            }
            
            if HMLoginManager.shared.networkState == .disconnect{
                self.p_addHistory(messages: tempMessages, completion: completion)
            }else{
                if tempMessages.count > 0 {
                    self.p_addHistory(messages: messages, completion: completion)
                }else{
                    ////数据库中已获取不到消息
                    //拿出当前最小的msgid去服务端取
                    self.loadHistoryFromServerBegin(msgID: self.getMinMsgID(), completion: { (count , error ) in
                        completion(count,error)
                    })
                }
            }
            
        }) { (error ) in
            completion(0,NSError.init(domain: error, code: HMErrorCode.db_query.rawValue, userInfo: nil ))
        }
        
    }
    
    func loadAllHistoryBegin(message:MTTMessageEntity,completion:@escaping HMLoadMoreHistoryMessageCompletion){
        
        let count:Int = self.p_getMessageCount()
        let predicate:NSPredicate = NSPredicate.init(format: "sessionId = \(self.sessionEntity.sessionID) AND messageID >= \(message.msgID)", argumentArray: nil )
        
        MTTMessageEntity.db_query(predicate: predicate, sortBy: "msgTime", sortAscending: false , offset: count , limitCount: 0, success: { (messages ) in
            self.p_addHistory(messages: messages, completion: completion)
        }) { (error ) in
            completion(0,NSError.init(domain: error, code: HMErrorCode.db_query.rawValue, userInfo: nil ))
        }
    }
    
    
    func getNewMsg(completion:@escaping HMLoadMoreHistoryMessageCompletion){
        HMMessageManager.shared.getMsgFromServer(beginMsgID: 0, forSession: self.sessionEntity, count: 20) { (messages , error ) in
            let maxmsgID:UInt32 = self.getMaxMsgID(messages: messages)
            if maxmsgID == 0 {
                completion(0,error as NSError?)
            }else{
                let sortor = NSSortDescriptor.init(key: "msgTime", ascending: true )
                let temp :NSArray = NSArray.init(array: messages)
                let sortedMessages = temp.sortedArray(using: [sortor]) as! [MTTMessageEntity]
                
                for obj in sortedMessages.enumerated(){
                    let message:MTTMessageEntity = obj.element
                    self.addShow(message: message)
                    
                    if message.msgID == maxmsgID {
                        HMMessageManager.shared.sendReadACK(message: message)
                    }
                }
                completion(sortedMessages.count,nil )
            }
        }
    }
    func loadHistoryFromServerBegin(msgID:UInt32 ,completion:@escaping HMLoadMoreHistoryMessageCompletion){
        
    }
    func loadHistoryFromServerBegin(msgID:UInt32,loadCount:Int ,completion:@escaping HMLoadMoreHistoryMessageCompletion){
        
    }
    
    func addShow(prompt:String){
        let prompt = HMPromptEntity.init(message: prompt)
        self.showingMessages.append(prompt)
    }
    
    func addShow(message:MTTMessageEntity){
        if !self.msgIDs.contains(message.msgID){
            if message.msgTime - lastestMsgDate > showPromtGap {
                lastestMsgDate = message.msgTime
                
                let prompt = HMPromptEntity.init(time: TimeInterval(message.msgTime))
                self.showingMessages.append(prompt)
            }
            
            self.showingMessages.append(message)
        }
    }
    
    func deleteShow(message:MTTMessageEntity){
        if self.msgIDs.contains(message.msgID){
            self.msgIDs.remove(at: self.msgIDs.index(of: message.msgID)!)
            
            for index in 0..<self.showingMessages.count{
                if let tempMsg = self.showingMessages[index] as? MTTMessageEntity{
                    if tempMsg.msgID == message.msgID{
                        self.showingMessages.remove(at: index)
                        return
                    }
                }
            }
        }
    }
    
    func updateSession(updateTime:TimeInterval ){
        self.sessionEntity.update(updateTime: updateTime)
        lastestMsgDate = UInt32(updateTime)
    }
    
    
    private func p_getMessageCount()->Int{
        var count:Int = 0
        for obj in showingMessages.enumerated(){
            if obj.element is MTTMessageEntity{
                count += 1
            }
        }
        
        return count
    }
    
    private func p_addHistory(messages:[Any],completion:@escaping HMLoadMoreHistoryMessageCompletion){
        
        let tempEarliestDate:UInt32 = (self.getMinMsgTime(messages: messages))
        var tempLastestDate:UInt32 = 0
        let itemCount = self.showingMessages.count
        
        var tempMessages:[Any] = []
        
        for obj in messages.reversed().enumerated(){
            if let message = obj.element as? MTTMessageEntity {
                if self.msgIDs.contains(message.msgID){
                
                }else{
                    if message.msgTime - tempLastestDate > showPromtGap {
                        let promt = DDPromptEntity.init()

                        let date = Date.init(timeIntervalSince1970: TimeInterval(message.msgTime))
                        promt.message = (date as NSDate) .promptDateString()
                        tempMessages.append(promt)
                    }
                    
                    tempLastestDate = message.msgTime
                    
                    self.msgIDs.append(message.msgID)
                    tempMessages.append(message)
                }
            }
        }
        
        if self.showingMessages.count == 0 {
            self.showingMessages.append(contentsOf: tempMessages)
            
            earliestMsgDate = tempEarliestDate
            lastestMsgDate = tempLastestDate
        }else{
            
            for index in 0..<tempMessages.count{
                self.showingMessages.insert(tempMessages[index], at: index)
            }
            earliestMsgDate = tempEarliestDate
        }
        
        let newItemCount = self.showingMessages.count
        
        let addCount = newItemCount - itemCount
        
        completion(addCount,nil)
    }
    
    func getMinMsgID()->UInt32 {
        if self.showingMessages.count == 0 {
            return self.sessionEntity.lastMsgID
        }
        
        var minID:UInt32 = self.getMaxMsgID(messages: self.showingMessages)
        
        for obj in  self.showingMessages.enumerated(){
            if let msg:MTTMessageEntity = obj.element as? MTTMessageEntity{
                if msg.msgID < minID {
                    minID = msg.msgID
                }
            }
        } 
        return minID
    }
    
    func getMaxMsgID(messages:[Any])->UInt32{
        var maxID:UInt32 = 0
        for obj in  messages.enumerated(){
            if let msg:MTTMessageEntity = obj.element as? MTTMessageEntity{
                if msg.msgID > maxID && msg.msgID < HM_Local_message_beginID {
                    maxID = msg.msgID
                }
            }
        }
        
        return maxID
    }
    
    func getMinMsgTime(messages:[Any])->UInt32{
        var minTime:UInt32 = UInt32(Date().timeIntervalSince1970 - 3600 * 24 * 180) //半年前
        for obj in  messages.enumerated(){
            if let msg:MTTMessageEntity = obj.element as? MTTMessageEntity{
                if msg.msgTime < minTime  {
                    minTime = msg.msgTime
                }
            }
        }
        return minTime
    }
    
    //Fixme:检查是否有丢失的消息
    func isHaveMissMsg(messages:[Any])->Bool{
        return false
    }
    
    //Fixme:检查是否连续并从服务端加载消息
    func checkMsgList(completion:HMLoadMoreHistoryMessageCompletion){
    
    }
}


class HMPromptEntity: NSObject {
    var message:String = ""
    var promptTime:TimeInterval = 0
    
    public convenience  init(time:TimeInterval) {
        self.init()
        
        let date = Date.init(timeIntervalSince1970: time)
        self.message = (date as NSDate).promptDateString()
        self.promptTime = time
    }
    public convenience  init(message:String) {
        self.init()
        
        self.message = message
        self.promptTime = Date().timeIntervalSince1970
    }
}


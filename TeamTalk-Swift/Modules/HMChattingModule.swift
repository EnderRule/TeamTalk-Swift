//
//  HMChattingModule.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/9/8.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

let HM_Message_Page_Item_Count:Int = 20

let HM_Local_message_beginID:UInt32 = 10000000

let showPromtGap:UInt32 = 300   //间隔多久需要显示时间提示标签

typealias HMLoadMoreHistoryMessageCompletion = ((Int,NSError?)->Void)  // callback : addcount and error

class HMChattingModule: NSObject {

    var sessionEntity:MTTSessionEntity!
    
    var msgIDs:[UInt32] = []
    
    var showingMessages:[Any] = []
    
    var lastestMsgDate:UInt32 = 0
    var earliestMsgDate:UInt32 = 0
    
    public convenience init(session:MTTSessionEntity) {
        self.init()
        
        self.sessionEntity = session
    }

    
    func loadMoreHistory(completion:HMLoadMoreHistoryMessageCompletion){
        
        
    }
    
    func loadAllHistoryBegin(message:MTTMessageEntity,completion:@escaping HMLoadMoreHistoryMessageCompletion){
        
        let count:Int = self.p_getMessageCount()
        let predicate:NSPredicate = NSPredicate.init(format: "sessionId = \(self.sessionEntity.sessionID) AND messageID >= \(message.msgID)", argumentArray: nil )
        
        MTTMessageEntity.db_query(predicate: predicate, sortBy: "msgTime", sortAscending: false , offset: count , limitCount: 0, success: { (messages ) in
            self.p_addHistory(messages: messages, completion: completion)
        }) { (error ) in
            completion(0,NSError.init(domain: error, code: 0, userInfo: nil ))
        }
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
}




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
    @objc optional func  sessionUpdate(session:MTTSessionEntity,action:HMSessionAction)
}


class HMSessionModule: NSObject {
    static let shared:HMSessionModule = HMSessionModule()
    
    
    private var currentSessions:[String:MTTSessionEntity] = [:]
    var delegate:HMSessionModuleDelegate?
    
    public func getAllSessions()->[MTTSessionEntity]{
        
        return []
    }
    
    public func add(session:MTTSessionEntity){
        if !currentSessions.keys.contains(session.sessionID){
            currentSessions.updateValue(session, forKey: session.sessionID)
        }
    }
    
    public func sessionFor(sessionID:String)->MTTSessionEntity?{
        return currentSessions[sessionID]
    }
    
    public func getRecentSessionFromServer(completion:((Void)->Void)?){
    
    }
    
}

//
//  MTTSessionEntity.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class MTTSessionEntity: NSObject {
    var sessionID:String = ""
    var sessionType:Im.BaseDefine.SessionType = .sessionTypeGroup
    
    private var s_name:String = ""
    var name:String {
        get{
            if s_name.length <= 0 {
                if self.sessionType == .sessionTypeSingle {
                    //Fixme:在此刷新数据
//                    [[DDUserModule shareInstance] getUserForUserID:_sessionID Block:^(MTTUserEntity *user) {
//                        if ([user.nick length] > 0)
//                        {
//                        name = user.nick;
//                        }
//                        else
//                        {
//                        name = user.name;
//                        }
//                        
//                        }];
                }else {
                    //Fixme:在此刷新数据
//                    MTTGroupEntity* group = [[DDGroupModule instance] getGroupByGId:_sessionID];
//                    if (!group) {
//                        [[DDGroupModule instance] getGroupInfogroupID:_sessionID completion:^(MTTGroupEntity *group) {
//                            name=group.name;
//                            }];
//                    }else{
//                        name=group.name;
//                    }
                }
            }
            return s_name
        }
        set{
            s_name = newValue
        }
    }
    var unReadMsgCount:Int = 0
    private var  s_timeInterval:TimeInterval = 0
    var timeInterval:TimeInterval {
        get{
            if s_timeInterval == 0 && self.sessionType == .sessionTypeSingle{
                //Fixme:在此刷新数据
//                [[DDUserModule shareInstance] getUserForUserID:_sessionID Block:^(MTTUserEntity *user) {
//                    timeInterval = user.lastUpdateTime;
//                    }];
            }
            return s_timeInterval
        }
        set{
            s_timeInterval = newValue
        }
    }
    var originId:String = ""
    var isShield:Bool = false
    var isFixedTop:Bool = false
    var lastMsg:String = ""
    var lastMsgID:Int = 0
    var avatar:String = ""
    
    var sessionUsers:[String] {
        get{
            if self.sessionType == .sessionTypeGroup{
                //Fixme:  fsfk
                return []
            }else{
                return []
            }
        }
    }
    
    var isGroupSession:Bool {
        get{
            return self.sessionType == .sessionTypeGroup
        }
    }
    
    
    public convenience init(sessionID:String,sessionName:String?,type:Im.BaseDefine.SessionType){
        self.init()
        
        self.sessionID = sessionID
        self.sessionType = type
        
        self.name = sessionName ?? ""
        self.lastMsg = ""
        self.lastMsgID = 0
        self.timeInterval = Date().timeIntervalSince1970
    }
    public func update(updateTime:TimeInterval){
        self.timeInterval = updateTime
        
        //Fixme:在此刷新数据
//        [[MTTDatabaseUtil instance] updateRecentSession:self completion:^(NSError *error) { }];
    }
    
    override var hash: Int {
        get{
            let sessionIDhash = self.sessionID.hash
            return sessionIDhash^Int(self.sessionType.rawValue)
        }
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if object == nil {
            return  false
        }else if (object! as? MTTSessionEntity) == nil  {
            return false
        }
        let other:MTTSessionEntity = object! as! MTTSessionEntity
        if other.sessionID != self.sessionID{
            return false
        }
        if other.sessionType != self.sessionType{
            return false
        }
        return true
    }
    
}


extension MTTSessionEntity {
    public convenience init(user:MTTUserEntity){
        self.init(sessionID: user.objID, sessionName: user.name, type: .sessionTypeSingle)
    }
    
    public convenience init(group:MTTGroupEntity){
        self.init(sessionID: group.objID, sessionName: group.name, type: .sessionTypeGroup)
    }
    
}

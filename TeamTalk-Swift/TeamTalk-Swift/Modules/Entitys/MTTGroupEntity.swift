//
//  MTTGroupEntity.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

enum MTTGroupType:Int{
    case fixed = 1
    case temporary
}

let GROUP_PRE:String = "group_"

class MTTGroupEntity: MTTBaseEntity {

    var groupCreatorId:String = ""
    var groupType:MTTGroupType = .temporary
    var name:String = ""
    var avatar:String = ""
    var groupUserIds:[String] = []
    var fixGroupUserIds:[String] = []  //固定的群用户列表IDS，用户生成群头像
    var lastMsg:String = ""
    var isShield:Bool = false
    
    func copyContent(otherGroup:MTTGroupEntity){
        self.groupType = otherGroup.groupType
        self.lastUpdateTime = otherGroup.lastUpdateTime
        self.name = otherGroup.name
        self.avatar = otherGroup.avatar
        self.groupUserIds = otherGroup.groupUserIds
        
    }
    
    public convenience init(dicInfo:[String:Any]){
        self.init()
        self.updateValues(info: dicInfo)
    }
    
    class func sessionID(groupID:String)->String{
        return groupID
    }
    
    
    
    
}


extension MTTGroupEntity {
    public convenience init(groupInfo:Im.BaseDefine.GroupInfo){
        self.init()
        //Fixme: update values here
    }
    
    class func pbIDFrom(localID:String)->UInt32{
        if localID.hasPrefix(GROUP_PRE){
            return  UInt32((localID.replacingOccurrences(of: GROUP_PRE, with: "") as NSString).intValue)
        }else {
            return 0
        }
    }
    class func localIDFrom(pbID:NSInteger)->String {
        return "\(GROUP_PRE)\(pbID)"
    }
    
}

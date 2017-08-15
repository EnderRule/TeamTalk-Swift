//
//  MTTGroupEntity.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit



let GROUP_PRE:String = "group_"

class MTTGroupEntity: MTTBaseEntity {

    var groupCreatorId:String = ""
    var groupType:Im.BaseDefine.GroupType = .groupTypeTmp
    var name:String = ""
    var avatar:String = ""
    
    private var s_groupUserIds:[String] = []
    var groupUserIds:[String] {
        get{
            return s_groupUserIds
        }
        set{
            s_groupUserIds.removeAll()
            fixGroupUserIds.removeAll()
            
            s_groupUserIds = newValue.sorted(by: { (obj1, obj2) -> Bool in
                let obj1_tmp = obj1.replacingOccurrences(of: USER_PRE, with: "") as NSString
                let obj2_tmp = obj2.replacingOccurrences(of: USER_PRE, with: "") as NSString
                
                return  obj1_tmp.integerValue > obj2_tmp.integerValue ? false : true
            })
            
            for obj in s_groupUserIds.enumerated(){
                self.addFixOrderGroupUserIDs(uID: obj.element )
            }
        }
    }
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
    
    
    func addFixOrderGroupUserIDs(uID:String){
        fixGroupUserIds.append(uID)
    }
}


extension MTTGroupEntity {
    public convenience init(groupInfo:Im.BaseDefine.GroupInfo){
        self.init()

        self.objID = MTTGroupEntity.localIDFrom(pbID: groupInfo.groupId)
        self.objectVersion = Int(groupInfo.version)
        self.name = groupInfo.groupName
        self.avatar = groupInfo.groupAvatar
        self.groupCreatorId = MTTUserEntity.localIDFrom(pbID: groupInfo.groupCreatorId)
        self.groupType = groupInfo.groupType
        self.isShield = groupInfo.shieldStatus == 1   //1:shield  0: not shield
        
        self.groupUserIds.removeAll()
        for obj in groupInfo.groupMemberList {
            let idstring:String = MTTUserEntity.localIDFrom(pbID: obj)
            self.groupUserIds.append(idstring)
        }
        self.lastMsg = ""
    }
    
    override class func pbIDFrom(localID:String)->UInt32{
        if localID.hasPrefix(GROUP_PRE){
            return  UInt32((localID.replacingOccurrences(of: GROUP_PRE, with: "") as NSString).intValue)
        }else {
            return 0
        }
    }
    override class func localIDFrom(pbID:UInt32)->String {
        return "\(GROUP_PRE)\(pbID)"
    }
    
}

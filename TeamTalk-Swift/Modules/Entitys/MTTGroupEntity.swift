//
//  MTTGroupEntity.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

//ID text UNIQUE,
//Avatar text,
//GroupType integer,
//Name text,
//CreatID text,
//Users Text,
//LastMessage Text,
//updated real,
//isshield integer,
//version integer)

import UIKit


@objc public enum GroupType_Objc:Int32 {
    case groupTypeNormal = 1
    case groupTypeTmp = 2
    
    public func toString() -> String {
        switch self {
        case .groupTypeNormal: return "GROUP_TYPE_NORMAL"
        case .groupTypeTmp: return "GROUP_TYPE_TMP"
        }
    }
    public static func fromString(_ str:String) throws -> GroupType_Objc {
        switch str {
        case "GROUP_TYPE_NORMAL":    return .groupTypeNormal
        case "GROUP_TYPE_TMP":    return .groupTypeTmp
        default: return .groupTypeNormal
        }
    }
    public var debugDescription:String { return getDescription() }
    public var description:String { return getDescription() }
    private func getDescription() -> String {
        switch self {
        case .groupTypeNormal: return ".groupTypeNormal"
        case .groupTypeTmp: return ".groupTypeTmp"
        }
    }
    public var hashValue:Int {
        return self.rawValue.hashValue
    }
    public static func ==(lhs:GroupType_Objc, rhs:GroupType_Objc) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}


let GROUP_PRE:String = "group_"

@objc(MTTGroupEntity)
class MTTGroupEntity: MTTBaseEntity,HMDBModelDelegate {

    func dbFields() -> [String] {
        return ["lastUpdateTime","objID","objectVersion","groupCreatorId",
                "name","avatar","lastMsg","isShield","type","users"]
    }
    
    func dbPrimaryKey() -> String? {
        return "objID"
    }
    
    var lastUpdateTime:Int32 = 0
    var objID:String = ""
    var objectVersion:Int32 = 0

    var groupCreatorId:Int32 = 0
    var name:String = ""
    var avatar:String = ""
    var lastMsg:String = ""
    var isShield:Bool = false
    var type:Int32 = 0
    
    var users:String = ""
    
    var groupType:GroupType_Objc = .groupTypeTmp{
        didSet{
            type = groupType.rawValue
        }
    }

    private var s_groupUserIds:[String] = []
    var groupUserIds:[String] {
        get{
            return s_groupUserIds
        }
        set{
            s_groupUserIds.removeAll()
            s_groupUserIds = newValue.sorted(by: { (obj1, obj2) -> Bool in
                return obj1.compare(obj2) == .orderedAscending
            })
            
            users = (s_groupUserIds as NSArray).componentsJoined(by:",")
            
            //fix
            fixGroupUserIds.removeAll()
            for obj in s_groupUserIds.enumerated(){
                self.addFixOrderGroupUserIDs(uID: obj.element )
            }
        }
    }
    var fixGroupUserIds:[String] = []  //固定的群用户列表IDS，用户生成群头像
    
    func copyContent(otherGroup:MTTGroupEntity){
        self.groupType = otherGroup.groupType
        self.lastUpdateTime = otherGroup.lastUpdateTime
        self.name = otherGroup.name
        self.avatar = otherGroup.avatar
        self.groupUserIds = otherGroup.groupUserIds
    }
    
     
    
    class func sessionID(groupID:String)->String{
        return groupID
    }
    
    
    public func addFixOrderGroupUserIDs(uID:String){
        fixGroupUserIds.append(uID)
    }
}


extension MTTGroupEntity {
    
    public convenience init(DicInfo:[String:Any]){
        self.init()
        
        self.updateValues(info:DicInfo)
    }
    
    public convenience init(groupInfo:Im.BaseDefine.GroupInfo){
        self.init()

        self.objID = MTTGroupEntity.localIDFrom(pbID: groupInfo.groupId)
        self.objectVersion = Int32(groupInfo.version)
        self.name = groupInfo.groupName
        self.avatar = groupInfo.groupAvatar
        self.groupCreatorId = Int32(groupInfo.groupCreatorId)
        self.groupType = GroupType_Objc.init(rawValue: groupInfo.groupType.rawValue) ?? .groupTypeNormal// groupInfo.groupType
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
            return UInt32((localID as NSString).intValue)
        }
    }
    override class func localIDFrom(pbID:UInt32)->String {
        return "\(GROUP_PRE)\(pbID)"
    }
    
}

//
//  MTTUserEntity.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

//ID text UNIQUE,
//Name text,
//Nick text,
//Avatar text,
//Department text,
//DepartID text,
//Email text,
//Postion text,
//Telphone text,
//Sex integer,
//updated real,
//pyname text,
//signature text

import UIKit
import CoreData








let USER_PRE:String = "user_"

@objc(MTTUserEntity)
public  class MTTUserEntity: MTTBaseEntity,HMDBModelDelegate {
    
    public func db()->MyFMDBQueue{
        return HMLoginManager.shared.myDBManager.dataBaseQueue
    }
    
    public func dbFields() -> [String] {
        return ["lastUpdateTime","objID","objectVersion","name","nick","avatar",
                "department","departId","signature","position","sex","telphone",
                "email","pyname","userStatus"]
    }
    public func dbPrimaryKeys() -> [String] {
        return ["objID"]
    }
    
    public var lastUpdateTime:Int32 = 0
    public var objID:String = "\(USER_PRE)0"
    public var objectVersion:Int32 = 0

    public var name:String = ""
    public var nick:String = ""
    public var avatar:String = "defaultAvatar"
    public var department:String = ""
    public var departId:String = ""

    public var signature:String = ""
    public var position:String = ""
    public var sex:Int32 = 0
    public var telphone:String = ""
    public var email:String = ""
    public var pyname:String = ""
    public var userStatus:Int32 = 0
    
    public var nickName:String {
        set {
            self.nick = newValue
        }
        get {
            return self.nick
        }
    }
    public var userId:String{
        set{
            self.objID = newValue
        }
        get{
            return self.objID
        }
    }
    public var intUserID:Int {
        return Int(MTTUserEntity.pbIDFrom(localID: self.userId))
    }
    
    public var isValided:Bool {
        get{
            return self.userId.length > 0 && self.intUserID > 0
        }
    }
    
    public var avatarUrl:String{
        get{
            if self.avatar.characters.count > 0 {
                return self.avatar
            }
            return "defaultAvatar"
        }
    }
    
//    public convenience init(dicInfo:[String:Any]){
//        self.init()
//        
//        self.updateValues(info: dicInfo)
//    }
//    
    func dicInfo()->[String:Any]{
        return self.dicValues()
    }
    
    public func sendEmail(){
        let stringURL = "mailto:\(self.email)"
        if let url = URL.init(string: stringURL){
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
                // Fallback on earlier versions
            }
        }
    }
    
    public func callPhoneNum () {
        let stringURL = "tel:\(self.telphone)"
        if let url = URL.init(string: stringURL){
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
                // Fallback on earlier versions
            }
        }
    }
    
    
    /// 设置默认值
//    override func awakeFromFetch() {
//        super.awakeFromFetch()
//        
//        self.objID = "\(USER_PRE)0"
//        self.name = ""
//        self.nick = ""
//        self.avatar = "defaultAvatar"
//        
//        self.lastUpdateTime = 0
//        self.objectVersion = 0
//        self.department = ""
//        self.departId = ""
//        self.signature = ""
//        self.position = ""
//        self.sex = 0
//        self.telphone = ""
//        self.email = ""
//        self.pyname = ""
//        self.userStatus = 1
//    } 

}

public extension MTTUserEntity{
    public class func  initWith(userinfo:Im.BaseDefine.UserInfo)->MTTUserEntity{
        let newUser:MTTUserEntity = MTTUserEntity.init()
        
        newUser.objID = "\(USER_PRE)\(userinfo.userId!)"
        newUser.name  = userinfo.userRealName
        newUser.nickName  = userinfo.userNickName
        newUser.avatar = userinfo.avatarUrl
        newUser.department = "\(userinfo.departmentId)"
        newUser.departId = "\(userinfo.departmentId)"
        newUser.telphone = userinfo.userTel
        newUser.sex =  Int32( userinfo.userGender)
        newUser.email = userinfo.email
        newUser.pyname = userinfo.userDomain
        newUser.userStatus = Int32(userinfo.status)
        newUser.signature = userinfo.signInfo
        
        return newUser
    }
    
    public override class func pbIDFrom(localID:String)->UInt32{
        if localID.hasPrefix(USER_PRE){
           return  UInt32((localID.replacingOccurrences(of: USER_PRE, with: "") as NSString).intValue)
        }else {
            return UInt32((localID as NSString).intValue)
        }
    }
    public override class func localIDFrom(pbID:UInt32)->String {
        return "\(USER_PRE)\(pbID)"
    }
}

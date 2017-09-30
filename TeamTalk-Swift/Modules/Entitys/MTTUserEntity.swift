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
class MTTUserEntity: MTTBaseEntity {
    
    @NSManaged var lastUpdateTime:Int32
    @NSManaged var objID:String
    @NSManaged var objectVersion:Int32

    @NSManaged var name:String
    @NSManaged var nick:String
    @NSManaged var avatar:String
    @NSManaged var department:String
    @NSManaged var departId:String

    @NSManaged var signature:String
    @NSManaged var position:String
    @NSManaged var sex:Int32
    @NSManaged var telphone:String
    @NSManaged var email:String
    @NSManaged var pyname:String
    @NSManaged var userStatus:Int32
    
    var nickName:String {
        set {
            self.nick = newValue
        }
        get {
            return self.nick
        }
    }
    var userId:String{
        set{
            self.objID = newValue
        }
        get{
            return self.objID
        }
    }
    var intUserID:Int {
        return Int(MTTUserEntity.pbIDFrom(localID: self.objID))
    }
    
    
    var isValided:Bool {
        get{
            Timer.init().invalidate()
            return self.userId.length > 0
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
    
    
    func sendEmail(){
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
    
    func callPhoneNum () {
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
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        self.objID = "\(USER_PRE)0"
        self.name = ""
        self.nickName = ""
        self.avatar = "defaultAvatar"
    }
    
    var avatarUrl:String{
        get {
            return self.avatar
        }
    }

}

extension MTTUserEntity{
    class func  initWith(userinfo:Im.BaseDefine.UserInfo)->MTTUserEntity{
        
        if let newUser:MTTUserEntity = MTTUserEntity.newNotInertObj() as? MTTUserEntity{
            print(" user entity ")
            
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
        }else {
            print("nil user entity ")

            return MTTUserEntity.init()
        }
    }
    
    override class func pbIDFrom(localID:String)->UInt32{
        if localID.hasPrefix(USER_PRE){
           return  UInt32((localID.replacingOccurrences(of: USER_PRE, with: "") as NSString).intValue)
        }else {
            return 0
        }
    }
    override class func localIDFrom(pbID:UInt32)->String {
        return "\(USER_PRE)\(pbID)"
    }
}

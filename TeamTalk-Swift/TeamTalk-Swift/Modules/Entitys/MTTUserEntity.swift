//
//  MTTUserEntity.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

let USER_PRE:String = "user_"

class MTTUserEntity: MTTBaseEntity {
    
    
    var name:String = ""
    var nick:String = ""
    var avatar:String = ""
    var department:String = ""
    var signature:String = ""
    var position:String = ""
    var sex:Int = 0
    var departId:String = ""
    var telphone:String = ""
    var email:String = ""
    var pyname:String = ""
    var userStatus:Int = 0
    
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
    
    public convenience  init(userID:String,name:String,nick:String,avatar:String,userRole:Int,userUpdated:Int ) {
        
        self.init()
        self.objID = userID
        self.name = name
        self.nick = nick
        self.avatar = avatar
        
        self.lastUpdateTime = Int32(userUpdated)
        
    }
    
    public convenience init(dicInfo:[String:Any]){
        self.init()
        
        self.updateValues(info: dicInfo)
    }
    
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
    
    var avatarUrl:String{
        get {
            return self.avatar
        }
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if object == nil {
            return  false
        }else if (object! as? MTTUserEntity) == nil  {
            return false
        }
        let other:MTTUserEntity = object! as! MTTUserEntity
        if other.objID != self.objID{
            return false
        }
        if other.name != self.name{
            return false
        }
        if other.nick != self.nick {
            return false
        }
        if other.pyname != self.pyname{
            return false
        }
        return true
    }
    
    override var hash: Int{
        let idhash = self.objID.hash
        let namehash = self.name.hash
        let nickhash = self.nick.hash
        let pynamehash = self.pyname.hash
        
        return idhash^namehash^nickhash^pynamehash
    }
}

extension MTTUserEntity{
    public convenience init(userinfo:Im.BaseDefine.UserInfo){
        self.init()
        
        self.objID = MTTUserEntity.localIDFrom(pbID: userinfo.userId)
        self.name  = userinfo.userRealName
        self.nickName  = userinfo.userNickName
        self.avatar = userinfo.avatarUrl
        self.department = "\(userinfo.departmentId)"
        self.departId = "\(userinfo.departmentId)"
        self.telphone = userinfo.userTel
        self.sex =  Int( userinfo.userGender)
        self.email = userinfo.email
        self.pyname = userinfo.userDomain
        self.userStatus = Int(userinfo.status)
        self.signature = userinfo.signInfo
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

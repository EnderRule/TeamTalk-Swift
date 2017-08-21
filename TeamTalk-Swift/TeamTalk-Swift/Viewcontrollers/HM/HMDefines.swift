//
//  HMDefines.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

//用到的一些常量


let DD_MESSAGE_IMAGE_PREFIX:String             = "&$#@~^@[{:"
let DD_MESSAGE_IMAGE_SUFFIX:String             = ":}]&$~@#@"


// url phone email 正则
let URL_REGULA = "((?:(http|https|Http|Https|rtsp|Rtsp):\\/\\/(?:(?:[a-zA-Z0-9\\$\\-\\_\\.\\+\\!\\*\\'\\(\\)\\,\\;\\?\\&\\=]|(?:\\%[a-fA-F0-9]{2})){1,64}(?:\\:(?:[a-zA-Z0-9\\$\\-\\_\\.\\+\\!\\*\\'\\(\\)\\,\\;\\?\\&\\=]|(?:\\%[a-fA-F0-9]{2})){1,25})?\\@)?)?((?:(?:[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}\\.)+(?:(?:aero|arpa|asia|a[cdefgilmnoqrstuwxz])|(?:biz|b[abdefghijmnorstvwyz])|(?:cat|com|coop|c[acdfghiklmnoruvxyz])|d[ejkmoz]|(?:edu|e[cegrstu])|f[ijkmor]|(?:gov|g[abdefghilmnpqrstuwy])|h[kmnrtu]|(?:info|int|i[delmnoqrst])|(?:jobs|j[emop])|k[eghimnrwyz]|l[abcikrstuvy]|(?:mil|mobi|museum|m[acdghklmnopqrstuvwxyz])|(?:name|net|n[acefgilopruz])|(?:org|om)|(?:pro|p[aefghklmnrstwy])|qa|r[eouw]|s[abcdeghijklmnortuvyz]|(?:tel|travel|t[cdfghjklmnoprtvwz])|u[agkmsyz]|v[aceginu]|w[fs]|y[etu]|z[amw]))|(?:(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9])\\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9]|0)\\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9]|0)\\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[0-9])))(?:\\:\\d{1,5})?)(\\/(?:(?:[a-zA-Z0-9\\;\\/\\?\\:\\@\\&\\=\\#\\~\\-\\.\\+\\!\\*\\'\\(\\)\\,\\_])|(?:\\%[a-fA-F0-9]{2}))*)?(?:\\b|$)"
let PHONE_REGULA = "\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[358]+\\d{9}|\\d{8}|\\d{7}"
let EMAIL_REGULA = "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"


let LINK_SPLIT = "!@#$~link~#$@!"
let NICK_SPLIT = "!@#$~nick~#$@!"
let PHONE_SPLIT = "!@#$~phone~#$@!"
let EMAIL_SPLIT = "!@#$~email~#$@!"

enum HMNotification:Int {
    
    //
    case tcpLinkConnectComplete = 1
    case tcpLinkConnectFailure
    case tcpLinkDisconnect
    case serverHeartBeat
    
    case userStartLogin                 //登录
    case userLoginSuccess
    case userLoginFailure
    case userLogout
    
    case userReloginSuccess             //重登
    case userReloginFailure
    case pcLoginStatusChanged           //PC 端登入状态改变
    
    //离线、被挤下线、主动下线、 用户签名修改
    case userOffline
    case userKickouted
    case userInitiativeOffline
    case userSignatureChanged
    
    
    case removeSessionSuccess           //移除会话
    case reloadRecentContacts           //刷新最近联系人页面
    case recentContactsUpdate           //最近联系人更新 ：例如用户成功加入群组时、用户登出时
    
    case loadLocalGroupFinish
    
    case receiveMessage
    case receiveP2PShakeMessage
    case receiveP2PInputingMessage
    case receiveP2PStopInputingMessage
    
    case sessionShieldAndFixed          //最近联系人置顶或者屏蔽
    
    func notificationName()->Notification.Name{
        let nameStr = "HMNotification\(self)"
        return Notification.Name.init(nameStr)
    }

    func postWith(obj:Any?,userInfo:[AnyHashable:Any]?){
        NotificationCenter.default.post(name: self.notificationName(), object: obj, userInfo: userInfo)
    }

}

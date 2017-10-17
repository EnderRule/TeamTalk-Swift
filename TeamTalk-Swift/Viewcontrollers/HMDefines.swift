//
//  HMDefines.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

//用到的一些常量

let disableHMLog:Bool = false

let SERVER_Address = "https://aitlg.linking.im/msg_server"  // "https://mapi.linking.im/" // "http://192.168.113.31:8080/msg_server"


// url phone email 正则
let URL_REGULA = "((?:(http|https|Http|Https|rtsp|Rtsp):\\/\\/(?:(?:[a-zA-Z0-9\\$\\-\\_\\.\\+\\!\\*\\'\\(\\)\\,\\;\\?\\&\\=]|(?:\\%[a-fA-F0-9]{2})){1,64}(?:\\:(?:[a-zA-Z0-9\\$\\-\\_\\.\\+\\!\\*\\'\\(\\)\\,\\;\\?\\&\\=]|(?:\\%[a-fA-F0-9]{2})){1,25})?\\@)?)?((?:(?:[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}\\.)+(?:(?:aero|arpa|asia|a[cdefgilmnoqrstuwxz])|(?:biz|b[abdefghijmnorstvwyz])|(?:cat|com|coop|c[acdfghiklmnoruvxyz])|d[ejkmoz]|(?:edu|e[cegrstu])|f[ijkmor]|(?:gov|g[abdefghilmnpqrstuwy])|h[kmnrtu]|(?:info|int|i[delmnoqrst])|(?:jobs|j[emop])|k[eghimnrwyz]|l[abcikrstuvy]|(?:mil|mobi|museum|m[acdghklmnopqrstuvwxyz])|(?:name|net|n[acefgilopruz])|(?:org|om)|(?:pro|p[aefghklmnrstwy])|qa|r[eouw]|s[abcdeghijklmnortuvyz]|(?:tel|travel|t[cdfghjklmnoprtvwz])|u[agkmsyz]|v[aceginu]|w[fs]|y[etu]|z[amw]))|(?:(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9])\\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9]|0)\\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9]|0)\\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[0-9])))(?:\\:\\d{1,5})?)(\\/(?:(?:[a-zA-Z0-9\\;\\/\\?\\:\\@\\&\\=\\#\\~\\-\\.\\+\\!\\*\\'\\(\\)\\,\\_])|(?:\\%[a-fA-F0-9]{2}))*)?(?:\\b|$)"
let PHONE_REGULA = "\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[358]+\\d{9}|\\d{8}|\\d{7}"
let EMAIL_REGULA = "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"


let maxChatContentWidth:CGFloat = (SCREEN_WIDTH() - 70.0 * 2.0)   //聊天cell的内容view的最大宽度

//字体大小
let fontTitle  = UIFont.systemFont(ofSize: 16)
let fontNormal = UIFont.systemFont(ofSize: 14)
let fontDetail = UIFont.systemFont(ofSize: 12)


enum HMNotification:Int {
    
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
    
    case sendMessageSucceed             //发送消息成功
    case receiveMsgReadACK          //收到消息已读回执
    case receiveMessage                 //收到普通新消息
    
    case receiveP2PShakeMessage
    case receiveP2PInputingMessage
    case receiveP2PStopInputingMessage
    
    case sessionShieldAndFixed          //最近联系人置顶或者屏蔽
    
    func notificationName()->Notification.Name{
        var nameStr = ""
        switch self  {
        case .tcpLinkDisconnect:
            nameStr = "Notification_Tcp_link_Disconnect"
            break
        case .tcpLinkConnectFailure:
            nameStr = "Notification_Tcp_Link_conntect_Failure"
            break
        case .tcpLinkConnectComplete:
            nameStr = "Notification_Tcp_Link_connect_complete"
            break
        case .serverHeartBeat:
            nameStr = "Notification_Server_heart_beat"
            break
        case .userStartLogin:
            nameStr = "Notification_Start_login"
            break
        case .userLoginSuccess:
            nameStr = "Notification_user_login_success"
            break
        case .userLoginFailure:
            nameStr = "Notification_user_login_failure"
            break
        case .userLogout:
            nameStr = "Notification_user_logout"
            break
//        case .userReloginSuccess:
//            nameStr = ""
//            break
//        case .userReloginFailure:
//            nameStr = ""
//            break
        case .pcLoginStatusChanged:
            nameStr = "Notification_pc_login_status_changed"
            break
        case .userOffline:
            nameStr = "Notification_user_off_line"
            break
        case .userKickouted:
            nameStr = "Notification_user_kick_out"
            break
        case .userInitiativeOffline:
            nameStr = "Notification_user_initiative_Offline"
            break
        case .userSignatureChanged:
            nameStr = "Notification_user_sign_changed"
            break
        case .removeSessionSuccess:
            nameStr = "Notification_Remove_Session"
            break
        case .reloadRecentContacts:
            nameStr = "Notification_reload_recent_contacts"
            break
        case .receiveMessage:
            nameStr = "Notification_receive_message"
            break
        case .receiveP2PShakeMessage:
            nameStr = "Notification_receive_P2P_Shake_message"
            break
        case .receiveP2PInputingMessage:
            nameStr = "Notifictaion_receive_P2P_Inputing_message"
            break
        case .receiveP2PStopInputingMessage:
            nameStr = "ReceiveP2PStopInputingMessage"
            break
        case .loadLocalGroupFinish:
            nameStr = "Notification_local_group"
            break
        case .recentContactsUpdate:
            nameStr = "Notification_RecentContactsUpdate"
            break
        case .sessionShieldAndFixed:
            nameStr = "Notification_SessionShieldAndFixed"
            break
        case .sendMessageSucceed:
            nameStr = "Notification_sendMessageSucceed"
        case .receiveMsgReadACK:
            nameStr = "Notification_receiveMsgReadACK"
            
        default:
            nameStr = "HMNotification_\(self)_\(self.rawValue)"
        }
        
        return Notification.Name.init(nameStr)
    }

    func postWith(obj:Any?,userInfo:[AnyHashable:Any]?){
        NotificationCenter.default.post(name: self.notificationName(), object: obj, userInfo: userInfo)
    }

}

enum HMErrorCode:Int {

    case db_add = 8801
    case db_insert = 8802
    case db_update = 8803
    case db_delete = 8804
    case db_query = 8805
    
}

func defaultToastStyle()->ToastStyle{
    var style = ToastStyle.init()
    style.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    style.activitySize = .init(width: 50, height: 50)
    style.cornerRadius = 8.0
    style.fadeDuration = 3.0
    style.imageSize = .init(width: 100, height: 100)
    return style
}

func HMPrint(items: Any...,file: String = #file, line: Int = #line, function: String = #function) {
    if !disableHMLog{
        print("HMPrint:\((file as NSString).lastPathComponent)->\(line)->\(function)->\(Date().timeIntervalSince1970):\(items) \n")
    }
}
//链接：http://www.jianshu.com/p/95460601cb6f


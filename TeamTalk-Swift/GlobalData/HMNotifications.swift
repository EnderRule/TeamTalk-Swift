//
//  HMNotifications.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/10/20.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import Foundation


@objc public enum HMNotification:Int {
    
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
    
    public func notificationName()->Notification.Name{
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
    
    public func postWith(obj:Any?,userInfo:[AnyHashable:Any]?){
        NotificationCenter.default.post(name: self.notificationName(), object: obj, userInfo: userInfo)
    }
}

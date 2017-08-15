//
//  DDNotification.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

enum DDNotification: String {
    
    case DDNotificationTcpLinkConnectComplete;          //tcp连接建立完成
    case DDNotificationTcpLinkConnectFailure;           //tcp连接建立失败
    case DDNotificationTcpLinkDisconnect;               //tcp断开连接
    case DDNotificationStartLogin;                      //用户开始登录
    case DDNotificationUserLoginFailure;                //用户登录失败
    case DDNotificationUserLoginSuccess;                //用户登录成功
    case DDNotificationUserReloginSuccess;              //用户断线重连成功
    case DDNotificationUserOffline;                     //用户离线
    case DDNotificationUserKickouted;                   //用户被挤下线
    case DDNotificationUserInitiativeOffline;           //用户主动离线
    case DDNotificationLogout;                          //用户登出
    case DDNotificationUserSignChanged;                 //用户签名修改广播
    case DDNotificationPCLoginStatusChanged;            //用户pc登陆状态修改广播
    case DDNotificationRemoveSession;                   //移除会话成功之后的通知
    case DDNotificationServerHeartBeat;                 //接收到服务器端的心跳
    case DDNotificationReceiveMessage;                  //收到一条消息
    case DDNotificationReloadTheRecentContacts;         //刷新最近联系人界面
    case DDNotificationReceiveP2PShakeMessage;          //收到P2P消息
    case DDNotificationReceiveP2PInputingMessage;       //收到正在输入消息
    case DDNotificationReceiveP2PStopInputingMessage;   //收到停止输入消息
    case DDNotificationLoadLocalGroupFinish;             //本地最近联系群加载完成
    case DDNotificationRecentContactsUpdate;              //最近联系人更新
    case MTTNotificationSessionShieldAndFixed;            //最近联系人置顶或者屏蔽
    
    var stringValue: String {
        return  String(describing: RawValue.self)
    }
    
    var notificationName: NSNotification.Name {
        return NSNotification.Name(stringValue)
    }
}





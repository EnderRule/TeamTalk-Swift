//
//  MTTDDNotification.h
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/16.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const kInvited;
extern NSString * const kUserSetting;
extern NSString * const kLastLoginUser;
extern NSString * const kHasAlertVIP;
extern NSString * const kLastPosition;
extern NSString * const kAccessToken;
extern NSString * const kRefreshToken;
extern NSString * const kTokenExpiredTime;
extern NSString * const kAPP_Version;
extern NSString * const kArrowCount;

extern NSString* const DDNotificationTcpLinkConnectComplete;          //tcp连接建立完成
extern NSString* const DDNotificationTcpLinkConnectFailure;           //tcp连接建立失败
extern NSString* const DDNotificationTcpLinkDisconnect;               //tcp断开连接
extern NSString* const DDNotificationStartLogin;                      //用户开始登录
extern NSString* const DDNotificationUserLoginFailure;                //用户登录失败
extern NSString* const DDNotificationUserLoginSuccess;                //用户登录成功
extern NSString* const DDNotificationUserReloginSuccess;              //用户断线重连成功
extern NSString* const DDNotificationUserOffline;                     //用户离线
extern NSString* const DDNotificationUserKickouted;                   //用户被挤下线
extern NSString* const DDNotificationUserKickouted;                   //用户被挤下线
extern NSString* const DDNotificationUserInitiativeOffline;           //用户主动离线
extern NSString* const DDNotificationLogout;                          //用户登出
extern NSString* const DDNotificationUserSignChanged;                 //用户签名修改广播
extern NSString* const DDNotificationPCLoginStatusChanged;            //用户pc登陆状态修改广播
extern NSString* const DDNotificationRemoveSession;                   //移除会话成功之后的通知
extern NSString* const DDNotificationServerHeartBeat;                 //接收到服务器端的心跳
extern NSString* const DDNotificationReceiveMessage;                  //收到一条消息
extern NSString* const DDNotificationReloadTheRecentContacts;         //刷新最近联系人界面
extern NSString* const DDNotificationReceiveP2PShakeMessage;          //收到P2P消息
extern NSString* const DDNotificationReceiveP2PInputingMessage;       //收到正在输入消息
extern NSString* const DDNotificationReceiveP2PStopInputingMessage;   //收到停止输入消息
extern NSString *const DDNotificationLoadLocalGroupFinish;             //本地最近联系群加载完成
extern NSString* const DDNotificationRecentContactsUpdate;              //最近联系人更新
extern NSString* const MTTNotificationSessionShieldAndFixed;            //最近联系人置顶或者屏蔽

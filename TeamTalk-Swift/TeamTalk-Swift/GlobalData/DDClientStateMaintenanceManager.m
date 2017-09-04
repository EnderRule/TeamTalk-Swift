//
//  DDClientStateMaintenanceManager.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-12.
//  Copyright (c) 2015年 MoguIM All rights reserved.
//

#import "DDClientStateMaintenanceManager.h"
#import "DDTcpClientManager.h"
#import "DDClientState.h"
#import "DDReachability.h"

#import "MTTDDNotification.h"

//#import "HeartbeatAPI.h"
//#import "LoginModule.h"
//#import "RecentUsersViewController.h"

#import "TeamTalk_Swift-Swift.h"

static NSInteger const heartBeatTimeinterval = 30;
static NSInteger const serverHeartBeatTimeinterval = 60;
static NSInteger const reloginTimeinterval = 5;

@interface DDClientStateMaintenanceManager(PrivateAPI)

//注册KVO
- (void)p_registerClientStateObserver;

//检验服务器端的心跳
- (void)p_startCheckServerHeartBeat;
- (void)p_stopCheckServerHeartBeat;
- (void)p_onCheckServerHeartTimer:(NSTimer*)timer;
- (void)n_receiveServerHeartBeat;

//客户端心跳
- (void)p_onSendHeartBeatTimer:(NSTimer*)timer;

//断线重连
- (void)p_startRelogin;
- (void)p_onReloginTimer:(NSTimer*)timer;
- (void)p_onReserverHeartTimer:(NSTimer*)timer;

@end

@implementation DDClientStateMaintenanceManager
{
    NSTimer* _sendHeartTimer;
    NSTimer* _reloginTimer;
    NSTimer* _serverHeartBeatTimer;
    
    BOOL _receiveServerHeart;
    NSUInteger _reloginInterval;
}
+ (instancetype)shareInstance
{
    static DDClientStateMaintenanceManager* g_clientStateManintenanceManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_clientStateManintenanceManager = [[DDClientStateMaintenanceManager alloc] init];
    });
    return g_clientStateManintenanceManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self p_registerClientStateObserver];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveServerHeartBeat) name:DDNotificationServerHeartBeat object:nil];
    }
    return self;
}

- (void)dealloc
{
//    DDLog(@"DDClientStateMaintenanceManager release");
    [[DDClientState shareInstance] removeObserver:self
                                       forKeyPath:DD_NETWORK_STATE_KEYPATH];
    
    [[DDClientState shareInstance] removeObserver:self
                                       forKeyPath:DD_USER_STATE_KEYPATH];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DDNotificationServerHeartBeat object:nil];
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    DDClientState* clientState = [DDClientState shareInstance];
    if ([keyPath isEqualToString:DD_NETWORK_STATE_KEYPATH])
    {
        if ([DDClientState shareInstance].networkState != DDNetWorkDisconnect)
        {
           
            BOOL shouldRelogin = !_reloginTimer && ![_reloginTimer isValid] && clientState.userState != DDUserOnline && clientState.userState != DDUserKickout && clientState.userState != DDUserOffLineInitiative;

            if (shouldRelogin)
            {
                _reloginTimer = [NSTimer scheduledTimerWithTimeInterval:reloginTimeinterval target:self selector:@selector(p_onReloginTimer:) userInfo:nil repeats:YES];
                _reloginInterval = 0;
                [_reloginTimer fire];
            }
        }else
        {
            clientState.userState=DDUserOffLine;
        }
    }

    else if ([keyPath isEqualToString:DD_USER_STATE_KEYPATH])
    {
        switch ([DDClientState shareInstance].userState)
        {
            case DDUserKickout:

                [self p_stopCheckServerHeartBeat];
                [self p_stopHeartBeat];
                break;
            case DDUserOffLine:

                [self p_stopCheckServerHeartBeat];
                [self p_stopHeartBeat];
                [self p_startRelogin];
                break;
            case DDUserOffLineInitiative:
                [self p_stopCheckServerHeartBeat];
                [self p_stopHeartBeat];
                break;
            case DDUserOnline:
                [self p_startCheckServerHeartBeat];
                [self p_startHeartBeat];
                break;
            case DDUserLogining:

                break;
        }
    }
    
}

#pragma mark private API

//注册KVO
- (void)p_registerClientStateObserver
{
    //网络状态
    [[DDClientState shareInstance] addObserver:self
                                    forKeyPath:DD_NETWORK_STATE_KEYPATH
                                       options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                       context:nil];
    
    //用户状态
    [[DDClientState shareInstance] addObserver:self
                                    forKeyPath:DD_USER_STATE_KEYPATH
                                       options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                       context:nil];
}

//开启发送心跳的Timer
-(void)p_startHeartBeat{
    
    if (!_sendHeartTimer && ![_sendHeartTimer isValid])
    {
        _sendHeartTimer = [NSTimer scheduledTimerWithTimeInterval: heartBeatTimeinterval
                                                           target: self
                                                         selector: @selector(p_onSendHeartBeatTimer:)
                                                         userInfo: nil
                                                          repeats: YES];
    }
}

//关闭发送心跳的Timer
- (void)p_stopHeartBeat
{
    if (_sendHeartTimer)
    {
        [_sendHeartTimer invalidate];
        _sendHeartTimer = nil;
    }
}

//开启检验服务器端心跳的Timer
- (void)p_startCheckServerHeartBeat
{
    //delete by kuaidao 20141022,In order to save mobile power,remove server heart beat
    if (!_serverHeartBeatTimer)
    {
//        DDLog(@"begin maintenance _serverHeartBeatTimer");
        _serverHeartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:serverHeartBeatTimeinterval target:self selector:@selector(p_onCheckServerHeartTimer:) userInfo:nil repeats:YES];
        [_serverHeartBeatTimer fire];
    }
}

//停止检验服务器端心跳的Timer
- (void)p_stopCheckServerHeartBeat
{
    if (_serverHeartBeatTimer)
    {
        [_serverHeartBeatTimer invalidate];
        _serverHeartBeatTimer = nil;
    }
}

//开启重连Timer
- (void)p_startRelogin
{
    if (!_reloginTimer)
    {
        _reloginTimer = [NSTimer scheduledTimerWithTimeInterval:reloginTimeinterval target:self selector:@selector(p_onReloginTimer:) userInfo:nil repeats:YES];
        [_reloginTimer fire];
    }
}

//运行在发送心跳的Timer上
- (void)p_onSendHeartBeatTimer:(NSTimer*)timer
{
    NSLog(@" *********嘣*********");
    
    HeartbeatAPI* heartBeatAPI = [[HeartbeatAPI alloc] init];
    [heartBeatAPI requestWithObject:nil Completion:nil];
}

//收到服务器端的数据包
- (void)n_receiveServerHeartBeat
{
    _receiveServerHeart = YES;
}

//运行在检验服务器端心跳的Timer上
- (void)p_onCheckServerHeartTimer:(NSTimer *)timer
{
    if (_receiveServerHeart)
    {
        _receiveServerHeart = NO;
    }
    else
    {
        [_serverHeartBeatTimer invalidate];
        _serverHeartBeatTimer = nil;
        //太久没收到服务器端数据包了
        DDLog(@"太久没收到服务器端数据包了~");
        [DDClientState shareInstance].userState = DDUserOffLine;
    }
}

//运行在断线重连的Timer上
- (void)p_onReloginTimer:(NSTimer*)timer
{
//    DDLog(@"p_ onRelogin Timer  ");
    
    static NSUInteger time = 0;
    static NSUInteger powN = 0;
    time ++;
    if (time >= _reloginInterval)
    {
        [[HMLoginManager shared]reloginWithSuccess:^(MTTUserEntity * _Nonnull user ) {
            DDLog(@"relogin success");
            
            [_reloginTimer invalidate];
            _reloginTimer = nil;
            time=0;
            _reloginInterval = 0;
            powN = 0;
            
            [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationUserLoginSuccess object:nil ];
            DDClientState.shareInstance.userState = DDUserOnline;
            [HMRecentSessionsViewController shared].title = APP_NAME;
        } failure:^(NSString * _Nonnull error ) {
            DDLog(@"relogin failure:%@",error);
            if ([error isEqualToString:@"未登录"]) {
                [_reloginTimer invalidate];
                _reloginTimer = nil;
                time = 0;
                _reloginInterval = 0;
                powN = 0;
                [HMRecentSessionsViewController shared].title = APP_NAME;
            }else{
                [HMRecentSessionsViewController shared].title = @"未连接";
                powN ++;
                time = 0;
                _reloginInterval = pow(2, powN);
            }
        }];
        
        
        
        
//        [[LoginModule instance] reloginSuccess:^{
//            DDLog(@"relogin success");
//
//            [_reloginTimer invalidate];
//            _reloginTimer = nil;
//            time=0;
//            _reloginInterval = 0;
//            powN = 0;
//
//            [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationUserLoginSuccess object:nil ];
//            DDClientState.shareInstance.userState = DDUserOnline;
//            [HMRecentSessionsViewController shared].title = APP_NAME;
//        } failure:^(NSString *error) {
//            DDLog(@"relogin failure:%@",error);
//            if ([error isEqualToString:@"未登录"]) {
//                [_reloginTimer invalidate];
//                _reloginTimer = nil;
//                time = 0;
//                _reloginInterval = 0;
//                powN = 0;
//                [HMRecentSessionsViewController shared].title = APP_NAME;
//            }else{
//                [HMRecentSessionsViewController shared].title = @"未连接";
//                powN ++;
//                time = 0;
//                _reloginInterval = pow(2, powN);
//            }
//            
//        }];
       
    }
}

@end

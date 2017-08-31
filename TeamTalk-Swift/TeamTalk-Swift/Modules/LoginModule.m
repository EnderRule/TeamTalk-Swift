//
//  DDLoginManager.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-5.
//  Copyright (c) 2015年 MoguIM All rights reserved.
//

#import "LoginModule.h"
#import "DDHttpServer.h"
#import "DDMsgServer.h"
#import "DDTcpServer.h"
#import "SpellLibrary.h"
#import "DDUserModule.h"

#import "DDClientState.h"
#import "RuntimeStatus.h"
//#import "ContactsModule.h"
#import "MTTDatabaseUtil.h"

//#import "SessionModule.h"
#import "DDGroupModule.h"
#import "MTTUtil.h"

#import "MTTDDNotification.h"
#import "TeamTalk_Swift-Swift.h"

@interface LoginModule(privateAPI)

- (void)p_loadAfterHttpServerWithToken:(NSString*)token userID:(NSString*)userID dao:(NSString*)dao password:(NSString*)password uname:(NSString*)uname success:(void(^)(MTTUserEntity* loginedUser))success failure:(void(^)(NSString* error))failure;
- (void)reloginAllFlowSuccess:(void(^)())success failure:(void(^)())failure;

@end

@implementation LoginModule
{
    NSString* _lastLoginUser;       //最后登录的用户ID
    NSString* _lastLoginPassword;
    NSString* _lastLoginUserName;
    NSString* _dao;
    NSString * _priorIP;
    NSInteger _port;
    BOOL _relogining;
}
+ (instancetype)instance
{
    static LoginModule *g_LoginManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_LoginManager = [[LoginModule alloc] init];
    });
    return g_LoginManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _httpServer = [[DDHttpServer alloc] init];
        _msgServer = [[DDMsgServer alloc] init];
        _tcpServer = [[DDTcpServer alloc] init];
        _relogining = NO;
    }
    return self;
}


#pragma mark Public API
- (void)loginWithUsername:(NSString*)userName password:(NSString*)password success:(void(^)(MTTUserEntity* loginedUser))success failure:(void(^)(NSString* error))failure
{

//    if (DEBUG) {
//        MTTUserEntity *user = [[ MTTUserEntity alloc]initWithUserID:@"user_4" name:@"qing" nick:@"qing" avatar:@"setting" userRole:1 userUpdated:1];
//        TheRuntime.user = user;
//        [DDClientState shareInstance].userState = DDUserOnline;
//        _relogining = YES;
//        
//        [[MTTDatabaseUtil instance]openCurrentUserDB];
//        [[SessionModule instance]loadLocalSession:^(bool isok) {
//            
//        }];
//        
//        success(user);
//        [[NSNotificationCenter defaultCenter] postNotificationName:DDNotificationUserLoginSuccess object:user];
//        return ;
//    }
    
    [_httpServer getMsgIp:^(NSDictionary *dic) {
        NSInteger code  = [[dic objectForKey:@"code"] integerValue];
        if (code == 0) {
            _priorIP = [dic objectForKey:@"priorIP"];
            _port    =  [[dic objectForKey:@"port"] integerValue];
            [MTTUtil setMsfsUrl:[dic objectForKey:@"msfsPrior"]];
            [_tcpServer loginTcpServerIP:_priorIP port:_port Success:^{
                
                NSNumber* clientType = @(17);
                NSString *clientVersion = [NSString stringWithFormat:@"MAC/%@-%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
                NSArray* parameter = @[userName,password,clientVersion,clientType];
                
                LoginAPI* api = [[LoginAPI alloc] init];
                [api requestWithObject:parameter Completion:^(id response, NSError *error) {
                    
                    if ((NSDictionary *)response){
                        MTTUserEntity *user = (MTTUserEntity *) response[@"user"];
                        if (user && user.isValided){
                            DDLog(@"login#登录验证成功 %@",userName);
                            _lastLoginPassword = password;
                            _lastLoginUserName = userName;
                            DDClientState* clientState = [DDClientState shareInstance];
                            clientState.userState=DDUserOnline;
                            _relogining=YES;

                            [RuntimeStatus instance].user=user;
                            [RuntimeStatus instance].userID=userName;
                            [RuntimeStatus instance].token=password;
                            [RuntimeStatus instance].autoLogin=YES;

                            
                            [[MTTDatabaseUtil instance] openCurrentUserDB];
                             
                            //加载所有人信息，创建检索拼音
                            [self p_loadAllUsersCompletion:^{
                                
                                if ([[SpellLibrary instance] isEmpty]) {
                                    
                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                        [[[DDUserModule shareInstance] getAllMaintanceUser] enumerateObjectsUsingBlock:^(MTTUserEntity *obj, NSUInteger idx, BOOL *stop) {
                                            [[SpellLibrary instance] addSpellForObject:obj];
                                            [[SpellLibrary instance] addDeparmentSpellForObject:obj];
                                            
                                        }];
                                        NSArray *array =  [[DDGroupModule instance] getAllGroups];
                                        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                            [[SpellLibrary instance] addSpellForObject:obj];
                                        }];
                                    });
                                }
                            }];
                            
                            [[SessionModule instance] loadLocalSession:^(bool isok) {}];
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:DDNotificationUserLoginSuccess object:user];

                            success(user);
                        }else{
                            NSString *resultString = (NSString *)response[@"resultString"];
                            if (!resultString || resultString.length <= 0 ){
                                resultString = [NSString stringWithFormat:@"登入失败：code = %@", response[@"resultCode"]];
                            }
                            failure(resultString);
                         }
                    } else {
                        DDLog(@"error:%@",[error domain]);
                        failure(error.description);
                    }
                }];
            } failure:^{
                DDLog(@"连接消息服务器失败 1");
                failure(@"连接消息服务器失败");
            }];
        }
    } failure:^(NSString *error) {
        DDLog(@"连接消息服务器失败 2");

         failure(@"连接消息服务器失败");
    }];
    
}

- (void)reloginSuccess:(void(^)())success failure:(void(^)(NSString* error))failure
{
    if ([DDClientState shareInstance].userState == DDUserOffLine && _lastLoginPassword && _lastLoginUserName) {
        
        [self loginWithUsername:_lastLoginUserName password:_lastLoginPassword success:^(MTTUserEntity *user) {
            [[NSNotificationCenter defaultCenter] postNotificationName:DDNotificationUserReloginSuccess object:user];
            success(YES);
        } failure:^(NSString *error) {
            failure(@"重新登陆失败");
        }];

    }
}

- (void)offlineCompletion:(void(^)())completion
{
    completion();
}



/**
 *  登录成功后获取所有用户
 *
 *  @param completion 异步执行的block
 */
- (void)p_loadAllUsersCompletion:(void(^)())completion
{
    __block NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    __block NSInteger version = [[defaults objectForKey:@"alllastupdatetime"] integerValue];
    
    [[MTTDatabaseUtil instance] getAllUsers:^(NSArray *contacts, NSError *error) {
        if ([contacts count] !=0) {
            [contacts enumerateObjectsUsingBlock:^(MTTUserEntity *obj, NSUInteger idx, BOOL *stop) {
                [[DDUserModule shareInstance] addMaintanceUser:obj];
            }];
            if (completion !=nil) {
                completion();
            }
        }else{
            version=0;
            AllUserAPI* api = [[AllUserAPI alloc] init];
            [api requestWithObject:@[@(version)] Completion:^(id response, NSError *error) {
                if (!error)
                {
                    NSUInteger responseVersion = [[response objectForKey:@"alllastupdatetime"] integerValue];
                    if (responseVersion == version && responseVersion !=0) {
                        
                        return ;
                        
                    }
                    [defaults setObject:@(responseVersion) forKey:@"alllastupdatetime"];
                    NSMutableArray *array = [response objectForKey:@"userlist"];
                    [[MTTDatabaseUtil instance] insertAllUser:array completion:^(NSError *error) {
                        
                    }];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [array enumerateObjectsUsingBlock:^(MTTUserEntity *obj, NSUInteger idx, BOOL *stop) {
                            [[DDUserModule shareInstance] addMaintanceUser:obj];
                        }];
                        
                        dispatch_async(dispatch_get_main_queue(),^{
                            if (completion !=nil) {
                                completion();
                            }
                        });
                    });
                }
            }];
        }
    }];
    
    AllUserAPI* api = [[AllUserAPI alloc] init];
    [api requestWithObject:@[@(version)] Completion:^(id response, NSError *error) {
        if (!error)
        {
            NSUInteger responseVersion = [[response objectForKey:@"alllastupdatetime"] integerValue];
            if (responseVersion == version && responseVersion !=0) {
                
                return ;

            }
            [defaults setObject:@(responseVersion) forKey:@"alllastupdatetime"];
            NSMutableArray *array = [response objectForKey:@"userlist"];
            [[MTTDatabaseUtil instance] insertAllUser:array completion:^(NSError *error) {
                
            }];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [array enumerateObjectsUsingBlock:^(MTTUserEntity *obj, NSUInteger idx, BOOL *stop) {
                    [[DDUserModule shareInstance] addMaintanceUser:obj];
                }];
            });
            
            
        }
    }];
    
}

@end

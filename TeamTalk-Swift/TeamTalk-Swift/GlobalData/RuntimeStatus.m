//
//  RuntimeStatus.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-07-31.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "RuntimeStatus.h"

//#import "DDGroupModule.h"
//#import "DDMessageModule.h"

#import "DDClientStateMaintenanceManager.h"
#import "AFHTTPSessionManager.h"
#import "MTTDDNotification.h"

#import "TeamTalk_Swift-Swift.h"

@interface RuntimeStatus()

@end

@implementation RuntimeStatus

+ (instancetype)instance
{
    static RuntimeStatus* g_runtimeState;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_runtimeState = [[RuntimeStatus alloc] init];
        
    });
    return g_runtimeState;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.user = [MTTUserEntity new];
        [self registerAPI];
        [self checkUpdateVersion];
        
        
        int length = 51;
        
        int8_t ch[4];
        for(int32_t i = 0;i<4;i++){
            ch[i] = ((length >> ((3 - i)*8)) & 0x0ff);
        }
        
        NSMutableData *data  = [[NSMutableData alloc]initWithBytes:ch  length:4];

        
        NSString *lengthStr = [NSString stringWithFormat:@"%d",length];
        NSString *str2 = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        NSLog(@"test:%hhd %hhd %hhd %hhd  \ntest2:%@ \ntest3:%@ \ntest4:%@",ch[0],ch[2],ch[2],ch[3],
              [lengthStr dataUsingEncoding:NSUTF8StringEncoding],
              str2,
              data);
    }
    return self;
}

-(void)checkUpdateVersion
{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    [manager GET:@"http://tt.mogu.io/tt/ios.json" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
//        double version = [responseDictionary[@"version"] doubleValue];
//        [MTTUtil setDBVersion:[responseDictionary[@"dbVersion"] intValue]];
//        
//        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//        
//        double app_Version = [[infoDictionary objectForKey:@"CFBundleShortVersionString"] doubleValue];
//        if (app_Version < version) {
//            self.updateInfo =@{@"haveupdate":@(YES),@"url":responseDictionary[@"url"]};
//        }else{
//              self.updateInfo =@{@"haveupdate":@(NO),@"url":@" "};
//        } 
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//    } ];
    
}
-(void)registerAPI
{
//    //接收踢出
    ReceiveKickOffAPI *receiveKick = [ReceiveKickOffAPI new];
    [receiveKick registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DDNotificationUserKickouted object:object];
    }];
//    //接收签名改变通知
    SignNotifyAPI *receiveSignNotify = [SignNotifyAPI new];
    [receiveSignNotify registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DDNotificationUserSignChanged object:object];
    }];
//    //接收pc端登陆状态变化通知
    LoginStatusNotifyAPI *receivePCLoginNotify = [LoginStatusNotifyAPI new];
    [receivePCLoginNotify registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DDNotificationPCLoginStatusChanged object:object];
    }];
}

-(void)updateData
{
    [DDMessageModule shareInstance];
    [DDClientStateMaintenanceManager shareInstance];
    [DDGroupModule instance];
}

-(NSString *)token{
    return (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"im.HMPassword"];
}
-(void)setToken:(NSString *)token{
    [[NSUserDefaults standardUserDefaults]setObject:token forKey:@"im.HMPassword"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(NSString *)userID{
    return (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"im.HMUserID"];
}
-(void)setUserID:(NSString *)userID{
    [[NSUserDefaults standardUserDefaults]setObject:userID forKey:@"im.HMUserID"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(BOOL)autoLogin{
    return [[NSUserDefaults standardUserDefaults]boolForKey:@"im.HMAutoLogin"];
}
-(void)setAutoLogin:(BOOL)autoLogin{
    [[NSUserDefaults standardUserDefaults]setBool:autoLogin forKey:@"im.HMAutoLogin"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

@end

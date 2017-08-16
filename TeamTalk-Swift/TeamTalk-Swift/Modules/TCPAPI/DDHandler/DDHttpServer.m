//
//  DDHttpServer.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-5.
//  Copyright (c) 2015年 MoguIM All rights reserved.
//

#import "DDHttpServer.h"
#import "MTTAFNetworkingClient.h"

@implementation DDHttpServer
- (void)loginWithUserName:(NSString*)userName
                 password:(NSString*)password
                  success:(void(^)(id respone))success
                  failure:(void(^)(id error))failure
{
//    DDHttpModule* module = [DDHttpModule shareInstance];
    NSMutableDictionary* dictParams = [NSMutableDictionary dictionary];
    [dictParams setObject:userName forKey:@"user_email"];
    [dictParams setObject:password forKey:@"user_pass"];
    [dictParams setObject:@"ooxx" forKey:@"macim"];
    [dictParams setObject:@"1.0" forKey:@"imclient"];
    [dictParams setObject:@"1" forKey:@"remember"];
    [MTTAFNetworkingClient jsonFormPOSTRequest:@"user/zlogin/" param:dictParams success:^(id result) {
        success(result);
    } failure:^(NSError * error) {
        failure(error);
    }];
    
}
-(void)getMsgIp:(void(^)(NSDictionary *dic))block failure:(void(^)(NSString* error))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
 
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:SERVER_ADDR parameters:nil  progress:nil  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        block(responseDictionary);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSString *errordes = error.domain;
        failure(errordes);
    }];
    
}
@end

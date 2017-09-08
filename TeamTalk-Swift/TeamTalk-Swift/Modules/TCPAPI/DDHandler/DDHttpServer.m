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

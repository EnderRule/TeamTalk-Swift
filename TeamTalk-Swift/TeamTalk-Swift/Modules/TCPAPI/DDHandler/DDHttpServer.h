//
//  DDHttpServer.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-5.
//  Copyright (c) 2015年 MoguIM All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDHttpServer : NSObject

-(void)getMsgIp:(void(^)(NSDictionary *dic))block failure:(void(^)(NSString* error))failure;
@end

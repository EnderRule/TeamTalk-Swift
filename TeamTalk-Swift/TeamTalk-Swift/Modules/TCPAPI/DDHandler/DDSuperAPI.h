//
//  DDSuperAPI.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-24.
//  Copyright (c) 2015年 MoguIM All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDAPIScheduleProtocol.h"
#import "DDTcpClientManager.h"
#import "DDDataOutputStream.h"
#import "DDDataInputStream.h"
#import "DataOutputStream+Addition.h"
#import "DDTcpProtocolHeader.h"
typedef void(^RequestCompletion)(id response,NSError* error);

/**
 *  这是一个超级类，不能被直接使用
 */
#define TimeOutTimeInterval 10

@interface DDSuperAPI : NSObject
@property (nonatomic,copy)RequestCompletion completion;
@property (nonatomic,readonly)uint16_t seqNo;

- (void)requestWithParameters:(NSDictionary *)parameters Completion:(RequestCompletion)completion;

@end

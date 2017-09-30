//
//  DDSuperAPI.h
//  Duoduo
//
//  Created by 独嘉 on 14-4-24.
//  Copyright (c) 2015年 MoguIM All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DDDataOutputStream.h"
#import "DDDataInputStream.h"

#import "DDTcpProtocolHeader.h"

typedef id(^Analysis)(NSData* data);
typedef NSMutableData*(^Package)(NSDictionary *parasDic,uint16_t seqNO);

@protocol DDAPIScheduleProtocol <NSObject>
@required

/**
 *  请求超时时间
 *
 *  @return 超时时间
 */
- (int)requestTimeOutTimeInterval;

/**
 *  请求的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)requestServiceID;

/**
 *  请求返回的serviceID
 *
 *  @return 对应的serviceID
 */
- (int)responseServiceID;

/**
 *  请求的commendID
 *
 *  @return 对应的commendID
 */
- (int)requestCommendID;

/**
 *  请求返回的commendID
 *
 *  @return 对应的commendID
 */
- (int)responseCommendID;

/**
 *  解析数据的block
 *
 *  @return 解析数据的block
 */
- (Analysis)analysisReturnData;

/**
 *  打包数据的block
 *
 *  @return 打包数据的block
 */
- (Package)packageRequestObject;
@end




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

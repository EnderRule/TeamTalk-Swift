//
//  DDUnrequestSuperAPI.h
//  Duoduo
//
//  Created by 独嘉 on 14-5-7.
//  Copyright (c) 2015年 MoguIM All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDDataInputStream.h"

#import "DDTcpClientManager.h"
#import "DDDataOutputStream.h"

#import "DDTcpProtocolHeader.h"

typedef id(^UnrequestAPIAnalysis)(NSData* data);

@protocol DDAPIUnrequestScheduleProtocol <NSObject>
@required
/**
 *  数据包中的serviceID
 *
 *  @return serviceID
 */
- (int)responseServiceID;

/**
 *  数据包中的commandID
 *
 *  @return commandID
 */
- (int)responseCommandID;

/**
 *  解析数据包
 *
 *  @return 解析数据包的block
 */
- (UnrequestAPIAnalysis)unrequestAnalysis;
@end



typedef void(^ReceiveData)(id object,NSError* error);

@interface DDUnrequestSuperAPI : NSObject
@property (nonatomic,copy)ReceiveData receivedData;
- (BOOL)registerAPIInAPIScheduleReceiveData:(ReceiveData)received;
@end

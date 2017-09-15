//
//  std.h
//  IOSDuoduo
//
//  Created by 东邪 on 14-5-23.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

//#import <UIKit/UIKit.h>
//#import <Foundation/Foundation.h>

#ifdef DEBUG
#define NEED_OUTPUT_LOG             1
#define Is_CanSwitchServer          1
#else
#define NEED_OUTPUT_LOG             0
#define Is_CanSwitchServer          0
#endif

#if NEED_OUTPUT_LOG
#define DDLog(xx, ...)                      NSLog(@"%s(%d) MGJLog: " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DDLog(xx, ...)                 nil
#endif

#define IM_PDU_HEADER_LEN   16
#define IM_PDU_VERSION      13

#define SERVER_ADDR                            @"http://192.168.113.31:8080/msg_server"

#define SYSTEM_VERSION        [[[UIDevice currentDevice] systemVersion] floatValue]

//#define STATUSBAR_HEIGHT      [[UIApplication sharedApplication] statusBarFrame].size.height
//#define NAVBAR_HEIGHT         (44.f + ((SYSTEM_VERSION >= 7) ? STATUSBAR_HEIGHT : 0))
//#define FULL_WIDTH            SCREEN_WIDTH
//#define FULL_HEIGHT           (SCREEN_HEIGHT - ((SYSTEM_VERSION >= 7) ? 0 : STATUSBAR_HEIGHT))
//#define CONTENT_HEIGHT        (FULL_HEIGHT - NAVBAR_HEIGHT)
//#define SCREEN_HEIGHT         [[UIScreen mainScreen] bounds].size.height
//#define SCREEN_WIDTH          [[UIScreen mainScreen] bounds].size.width

#undef	AS_SINGLETON
#define AS_SINGLETON( __class ) \
+ (__class *)sharedInstance;

#undef	DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
+ (__class *)sharedInstance \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[__class alloc] init]; } ); \
return __singleton__; \
}

#define LOCAL_MSG_BEGIN_ID 1000000

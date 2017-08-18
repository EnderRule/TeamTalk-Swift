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
#define DDLog(xx, ...)                      NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DDLog(xx, ...)                 nil
#endif

#define IM_PDU_HEADER_LEN   16
#define IM_PDU_VERSION      13

#define SERVER_ADDR                            @"http://192.168.113.31:8080/msg_server" //@"http://61.153.100.221:8080/msg_server"

#define _(x)                                NSLocalizedString(x,@"")


#define objectOrNull(obj) ((obj) ? (obj) : [NSNull null])
#define objectOrEmptyStr(obj) ((obj) ? (obj) : @"")

#define isNull(x)             (!x || [x isKindOfClass:[NSNull class]])
#define toInt(x)              (isNull(x) ? 0 : [x intValue])
#define isEmptyString(x)      (isNull(x) || [x isEqual:@""] || [x isEqual:@"(null)"])

#define sleep(s);             [NSThread sleepForTimeInterval:s];
#define Syn(x)                @synthesize x = _##x

#define RGBA(r,g,b,a)         [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define RGB(r,g,b)            [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define BoldSystemFont(size)  [UIFont boldSystemFontOfSize:size]
#define systemFont(size)      [UIFont systemFontOfSize:size]
#define beginAutoPool         NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init]; {
#define endAutoPool           } [pool release];
#define skipspace(c)          while (isspace(*c)) ++c
#define skipUntil(c,x)        while (x != *c) ++c
#define TheWindowHeight      ([UIDevice isAfterOS7] ? [UIScreen mainScreen].bounds.size.height : ([UIScreen mainScreen].bounds.size.height - 20))
#define IntToNumber(int)        ([NSNumber numberWithInt:int])
#define isIOS7 [[UIDevice currentDevice].systemVersion doubleValue]>=7.0?YES:NO
#define isIOS8 [[UIDevice currentDevice].systemVersion doubleValue]>=8.0?YES:NO
#define SYSTEM_VERSION        [[[UIDevice currentDevice] systemVersion] floatValue]
#define STATUSBAR_HEIGHT      [[UIApplication sharedApplication] statusBarFrame].size.height
#define NAVBAR_HEIGHT         (44.f + ((SYSTEM_VERSION >= 7) ? STATUSBAR_HEIGHT : 0))
#define FULL_WIDTH            SCREEN_WIDTH
#define FULL_HEIGHT           (SCREEN_HEIGHT - ((SYSTEM_VERSION >= 7) ? 0 : STATUSBAR_HEIGHT))
#define CONTENT_HEIGHT        (FULL_HEIGHT - NAVBAR_HEIGHT)

// 屏幕高度
#define SCREEN_HEIGHT         [[UIScreen mainScreen] bounds].size.height
// 屏幕宽度
#define SCREEN_WIDTH          [[UIScreen mainScreen] bounds].size.width

#define PhotosMessageDir ([[NSString documentPath] stringByAppendingPathComponent:@"/PhotosMessageDir/"])
#define IPHONE4 ( [ [ UIScreen mainScreen ] bounds ].size.height == 480 )

#define APP_NAME  [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleDisplayName"]// @"TeamTalk"
#define APP_Version [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleShortVersionString"]

//字体颜色
#define GRAYCOLOR RGB(137, 139, 144)
#define TTBLUE RGB(1, 175, 244)
#define TTGRAY RGB(153, 153, 153)
#define TTCELLGRAY RGB(217, 217, 217)
#define TTBG RGB(239, 239, 244)

#define FileManager     ([NSFileManager defaultManager])
#define TheUserDefaults ([NSUserDefaults standardUserDefaults])
#define VoiceMessageDir ([[NSString documentPath] stringByAppendingPathComponent:@"/VoiceMessageDir/"])
#define BlacklistDir ([[NSString documentPath] stringByAppendingPathComponent:@"/BlacklistDir/"])
#define Departmentlist ([[NSString documentPath] stringByAppendingPathComponent:@"/department.plist"])
#define fixedlist ([[NSString documentPath] stringByAppendingPathComponent:@"/fixed.plist"])
#define shieldinglist ([[NSString documentPath] stringByAppendingPathComponent:@"/shieldingArray.plist"])


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

//快速定义一个weakSelf 用于block
#define MTT_WEAKSELF(weakSelf)  __weak __typeof(&*self)weakSelf = self;

#define MAX_CHAT_TEXT_WIDTH (SCREEN_WIDTH - 70.0*2)

//图片
#define DD_MESSAGE_IMAGE_PREFIX             @"&$#@~^@[{:"
#define DD_MESSAGE_IMAGE_SUFFIX             @":}]&$~@#@"

// url phone email 正则
#define URL_REGULA @"((?:(http|https|Http|Https|rtsp|Rtsp):\\/\\/(?:(?:[a-zA-Z0-9\\$\\-\\_\\.\\+\\!\\*\\'\\(\\)\\,\\;\\?\\&\\=]|(?:\\%[a-fA-F0-9]{2})){1,64}(?:\\:(?:[a-zA-Z0-9\\$\\-\\_\\.\\+\\!\\*\\'\\(\\)\\,\\;\\?\\&\\=]|(?:\\%[a-fA-F0-9]{2})){1,25})?\\@)?)?((?:(?:[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}\\.)+(?:(?:aero|arpa|asia|a[cdefgilmnoqrstuwxz])|(?:biz|b[abdefghijmnorstvwyz])|(?:cat|com|coop|c[acdfghiklmnoruvxyz])|d[ejkmoz]|(?:edu|e[cegrstu])|f[ijkmor]|(?:gov|g[abdefghilmnpqrstuwy])|h[kmnrtu]|(?:info|int|i[delmnoqrst])|(?:jobs|j[emop])|k[eghimnrwyz]|l[abcikrstuvy]|(?:mil|mobi|museum|m[acdghklmnopqrstuvwxyz])|(?:name|net|n[acefgilopruz])|(?:org|om)|(?:pro|p[aefghklmnrstwy])|qa|r[eouw]|s[abcdeghijklmnortuvyz]|(?:tel|travel|t[cdfghjklmnoprtvwz])|u[agkmsyz]|v[aceginu]|w[fs]|y[etu]|z[amw]))|(?:(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9])\\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9]|0)\\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9]|0)\\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[0-9])))(?:\\:\\d{1,5})?)(\\/(?:(?:[a-zA-Z0-9\\;\\/\\?\\:\\@\\&\\=\\#\\~\\-\\.\\+\\!\\*\\'\\(\\)\\,\\_])|(?:\\%[a-fA-F0-9]{2}))*)?(?:\\b|$)"
#define PHONE_REGULA @"\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[358]+\\d{9}|\\d{8}|\\d{7}"
#define EMAIL_REGULA @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"


#define LINK_SPLIT @"!@#$~link~#$@!"
#define NICK_SPLIT @"!@#$~nick~#$@!"
#define PHONE_SPLIT @"!@#$~phone~#$@!"
#define EMAIL_SPLIT @"!@#$~email~#$@!"



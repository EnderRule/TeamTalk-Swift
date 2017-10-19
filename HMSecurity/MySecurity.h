//
//  Security.h
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/10/19.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface  MySecurity:NSObject

+(NSString *)encrypt:(NSString *)str;

+(NSString *)decrypt:(NSString *)str;

@end

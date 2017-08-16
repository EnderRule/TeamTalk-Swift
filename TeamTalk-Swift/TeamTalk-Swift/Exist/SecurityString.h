//
//  SecurityString.h
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/16.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecurityString : NSString

-(NSString *)Encrypt;
-(NSString *)Decrypt;

@end

//
//  MTTUtil.m
//  TeamTalk
//
//  Created by 宪法 on 15/6/18.
//  Copyright (c) 2015年 MoguIM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTTUtil.h"

 #import "DDTcpClientManager.h"

//#import "SessionModule.h"
//#import "DDMessageModule.h"


@implementation MTTUtil

#pragma mark - 拼音

+(char)pinyinFirstLetter:(unsigned short)hanzi{
    int index = hanzi - HANZI_START;
    if (index >= 0 && index <= HANZI_COUNT)
    {
        return firstLetterArray[index];
    }
    else
    {
        return '#';
    }
}

+(char)getFirstChar:(const NSString *)str{
    if (nil == str || 0 == [str length]) {
        return '#';
    }
    const char * firstChar = [str UTF8String];
    if ( ('a'<=  *firstChar && *firstChar <= 'z')
        || ('A' <= *firstChar && *firstChar <= 'Z')) {
        return *firstChar;
    }
    else {
        return [MTTUtil pinyinFirstLetter:[str characterAtIndex:0]];
    }
}


#pragma mark - OriginalID & sessionID

+(UInt32)changeIDToOriginal:(NSString *)sessionID
{
    NSArray *array = [sessionID componentsSeparatedByString:@"_"];
    if (array.count >= 2 && array[1]) {
        return [array[1] unsignedIntValue];
    }
    return 0;
}

#pragma mark - new function

+(BOOL)isUseFunctionBubble{
    
    NSNumber *number =[[NSUserDefaults standardUserDefaults] objectForKey:@"UseFunctionBubble"];
    return [number boolValue];
}

+(void)useFunctionBubble{
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"UseFunctionBubble"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - fiexed top
+(void)setFixedTop:(NSString *)sessionID{
    NSArray *allUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"fixedTopUsers"];
    NSMutableArray *allUserTmp =[NSMutableArray arrayWithArray:allUser];
    [allUserTmp addObject:sessionID];
    [[NSUserDefaults standardUserDefaults] setObject:allUserTmp forKey:@"fixedTopUsers"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSArray *)getFixedTop{
    NSArray *allUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"fixedTopUsers"];
    return allUser;
}

+(void)removeFixedTop:(NSString *)sessionID{
    NSArray *allUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"fixedTopUsers"];
    NSMutableArray *allUserTmp =[NSMutableArray arrayWithArray:allUser];
    [allUserTmp removeObject:sessionID];
    [[NSUserDefaults standardUserDefaults] setObject:allUserTmp forKey:@"fixedTopUsers"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)checkFixedTop:(NSString *)sessionID{
    NSArray *allUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"fixedTopUsers"];
    return [allUser containsObject:sessionID];
}

+(CGSize)sizeTrans:(CGSize)size{
    float width;
    float height;
    float imgWidth = size.width;
    float imgHeight = size.height;
    float radio = size.width/size.height;
    if(radio>=1){
        width = imgWidth > MAX_CHAT_TEXT_WIDTH ? MAX_CHAT_TEXT_WIDTH : imgWidth;
        height = imgWidth > MAX_CHAT_TEXT_WIDTH ? (imgHeight * MAX_CHAT_TEXT_WIDTH / imgWidth):imgHeight;
    }else{
        height = imgHeight > MAX_CHAT_TEXT_WIDTH ? MAX_CHAT_TEXT_WIDTH : imgHeight;
        width = imgHeight > MAX_CHAT_TEXT_WIDTH ? (imgWidth * MAX_CHAT_TEXT_WIDTH / imgHeight):imgWidth;
    }
    return CGSizeMake(width, height);
}

#pragma mark - 气泡功能
+(NSString *)getBubbleTypeLeft:(BOOL)left
{
    NSString *bubbleType;
    if(left){
        bubbleType = [[NSUserDefaults standardUserDefaults] objectForKey:@"userLeftCustomerBubble"];
        if(!bubbleType){
            bubbleType = @"default_white";
        }
    }else{
        bubbleType = [[NSUserDefaults standardUserDefaults] objectForKey:@"userRightCustomerBubble"];
        if(!bubbleType){
            bubbleType = @"default_blue";
        }
    }
    return bubbleType;
}

+(void)setBubbleTypeLeft:(NSString *)bubbleType left:(BOOL)left
{
    if(left){
        [[NSUserDefaults standardUserDefaults] setObject:bubbleType forKey:@"userLeftCustomerBubble"];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:bubbleType forKey:@"userRightCustomerBubble"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)setLastPhotoTime:(NSDate *)date
{
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"preShowImageTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSDate *)getLastPhotoTime
{
    NSDate *lastDate = [[NSDate alloc] initWithTimeInterval:-90 sinceDate:[NSDate date]];
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"preShowImageTime"];
    if(date){
        return date;
    }else{
        return lastDate;
    }
}

+(void)setLastShakeTime:(NSDate *)date
{
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"shakePcTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(BOOL)ifCanShake
{
    NSDate *date = [[NSDate alloc] initWithTimeInterval:-10 sinceDate:[NSDate date]];
    NSDate *preDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"shakePcTime"];
    if(!preDate){
        return YES;
    }
    if([date compare:preDate] == NSOrderedDescending){
        return YES;
    }else{
        return NO;
    }
}
+(void)setDBVersion:(NSInteger)version
{
    [[NSUserDefaults standardUserDefaults] setInteger:version forKey:@"dbVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSInteger)getDBVersion
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"dbVersion"];
}
+(void)setLastDBVersion:(NSInteger)version
{
    [[NSUserDefaults standardUserDefaults] setInteger:version forKey:@"lastDbVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSInteger)getLastDBVersion
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"lastDbVersion"];
}

@end

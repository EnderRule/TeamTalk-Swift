//
//  MTTBubble.m
//  TeamTalk
//
//  Created by scorpio on 15/7/2.
//  Copyright (c) 2015年 MoguIM. All rights reserved.
//

#import "MTTBubbleModule.h"

@implementation MTTBubbleModule
{
    MTTBubbleConfig* _left_config;
    MTTBubbleConfig* _right_config;
}
+ (instancetype)shareInstance
{
    static MTTBubbleModule* g_bubbleModule;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_bubbleModule = [MTTBubbleModule new];
    });
    
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        g_bubbleModule = [[MTTBubbleModule alloc] init];
//    });
    return g_bubbleModule;
}

- (instancetype)init
{
    //
    self = [super init];
    if (self)
    {
        NSString* leftBubbleType = [MTTBubbleModule getBubbleTypeLeft:YES];
        NSString* rightBubbleType = [MTTBubbleModule getBubbleTypeLeft:NO];
        NSString* leftBubblePath = [[NSString alloc]initWithFormat:@"bubble.bundle/%@/config.json", leftBubbleType];
        NSString* rightBubblePath = [[NSString alloc]initWithFormat:@"bubble.bundle/%@/config.json", rightBubbleType];
        NSString* leftPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:leftBubblePath];
        NSString* rightPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:rightBubblePath];

        _left_config = [[MTTBubbleConfig alloc] initWithConfig:leftPath left:YES];
        _right_config = [[MTTBubbleConfig alloc] initWithConfig:rightPath left:NO];
        
    }
    return self;
    
}

- (MTTBubbleConfig*)getBubbleConfigLeft:(BOOL)left
{
    if(left){
        return _left_config;
    }
    return _right_config;
}

- (void)selectBubbleTheme:(NSString *)bubbleType left:(BOOL)left
{
    [MTTBubbleModule setBubbleTypeLeft:bubbleType left:left];
    NSString* path = [[NSString alloc]initWithFormat:@"bubble.bundle/%@/config.json", bubbleType];
    NSString* realPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:path];
    if(left){
        _left_config = [[MTTBubbleConfig alloc] initWithConfig:realPath left:(BOOL)left];
    }else{
        _right_config = [[MTTBubbleConfig alloc] initWithConfig:realPath left:(BOOL)left];
    }
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

+ (NSString *)getBubbleTypeLeft:(BOOL)left
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

@end

@implementation MTTBubbleConfig

- (instancetype)initWithConfig:(NSString*)string left:(BOOL)left
{
    self = [super init];
    if (self)
    {
        NSData* data = [NSData dataWithContentsOfFile:string];
        
        if (data){
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
            MTTBubbleContentInset insetTemp;
            insetTemp.top = [dic[@"contentInset"][@"top"] floatValue];
            insetTemp.bottom = [dic[@"contentInset"][@"bottom"] floatValue];
            if(left){
                insetTemp.left = [dic[@"contentInset"][@"left"] floatValue];
                insetTemp.right = [dic[@"contentInset"][@"right"] floatValue];
            }else{
                insetTemp.left = [dic[@"contentInset"][@"right"] floatValue];
                insetTemp.right = [dic[@"contentInset"][@"left"] floatValue];
            }
            self.inset = insetTemp;
            MTTBubbleVoiceInset voiceInsetTemp;
            voiceInsetTemp.top = [dic[@"voiceInset"][@"top"] floatValue];
            voiceInsetTemp.bottom = [dic[@"voiceInset"][@"bottom"] floatValue];
            if(left){
                voiceInsetTemp.left = [dic[@"voiceInset"][@"left"] floatValue];
                voiceInsetTemp.right = [dic[@"voiceInset"][@"right"] floatValue];
            }else{
                voiceInsetTemp.left = [dic[@"voiceInset"][@"right"] floatValue];
                voiceInsetTemp.right = [dic[@"voiceInset"][@"left"] floatValue];
            }
            self.voiceInset = voiceInsetTemp;
            MTTBubbleStretchy stretchyTemp;
            stretchyTemp.left = [dic[@"stretchy"][@"left"] floatValue];
            stretchyTemp.top = [dic[@"stretchy"][@"top"] floatValue];
            self.stretchy = stretchyTemp;
            MTTBubbleStretchy imgStretchyTemp;
            imgStretchyTemp.left = [dic[@"imgStretchy"][@"left"] floatValue];
            imgStretchyTemp.top = [dic[@"imgStretchy"][@"top"] floatValue];
            self.imgStretchy = imgStretchyTemp;
            NSArray *textColorTemp = [dic[@"textColor"] componentsSeparatedByString:@","];
                
                
                self.textColor = [UIColor colorWithRed:[textColorTemp[0] floatValue] green:[textColorTemp[1] floatValue] blue:[textColorTemp[2] floatValue] alpha:1];
            NSArray *linkColorTemp = [dic[@"linkColor"] componentsSeparatedByString:@","];
            self.linkColor =  [UIColor colorWithRed:[linkColorTemp[0] floatValue] green:[linkColorTemp[1] floatValue] blue:[linkColorTemp[2] floatValue] alpha:1]; 
            
            NSString* textBgImagePath;
            NSString* picBgImagePath;
            NSString* bubbleType = [MTTBubbleModule getBubbleTypeLeft:left];
            if(left){
                textBgImagePath = [[NSString alloc]initWithFormat:@"bubble.bundle/%@/textLeftBubble", bubbleType];
                picBgImagePath = [[NSString alloc]initWithFormat:@"bubble.bundle/%@/picLeftBubble", bubbleType];
            }else{
                textBgImagePath = [[NSString alloc]initWithFormat:@"bubble.bundle/%@/textBubble", bubbleType];
                picBgImagePath = [[NSString alloc]initWithFormat:@"bubble.bundle/%@/picBubble", bubbleType];
            }
            
    //        self.textBgImage = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:textBgImagePath];
            self.textBgImage = textBgImagePath;
    //        self.picBgImage = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:picBgImagePath];
            self.picBgImage = picBgImagePath;
        }
    }
    return self;
}

@end

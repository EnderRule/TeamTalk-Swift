//
//  NTESInputMoreContainerView.h
//  NIMDemo
//
//  Created by chris.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIMInputViewConfig.h"
#import "NIMInputProtocol.h"


@interface NIMInputMoreContainerView : UIView

@property (nonatomic,weak)  id<NIMInputViewConfig> config;
@property (nonatomic,weak)  id<NIMInputActionDelegate> actionDelegate;

@end

//
//  NIMInputViewConfig.h
//  NIMKit
//
//  Created by amao on 8/12/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NIMMediaItem.h"

#import "NIMInputBarItemType.h"


@protocol NIMInputViewConfig <NSObject>

/**
 *  是否禁用輸入控件 中的 @ 某人符號
 */
- (BOOL)disableAtUser;

@optional

/**
 *  輸入按鈕類型，請填入 NIMInputBarItemType 枚舉，按順序排列。不實現則按默認排列。
 */
- (NSArray<NSNumber *> *)inputBarItemTypes;


/**
 *  可以顯示在點擊輸入框「+」按鈕之後的多媒體按鈕
 */
- (NSArray<NIMMediaItem *> *)mediaItems;


/**
 *  禁用貼圖表情
 */
- (BOOL)disableCharlet;


/**
 *  是否禁用輸入控件
 */
- (BOOL)disableInputView;





@end

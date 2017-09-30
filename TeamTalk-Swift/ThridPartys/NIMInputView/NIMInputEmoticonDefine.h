//
//  NIMInputEmoticonDefine.h
//  NIMKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#ifndef NIMKit_NIMInputEmoticonDefine_h
#define NIMKit_NIMInputEmoticonDefine_h

#define NIMKit_EmojiBundleName                             @"NIMKitEmotion.bundle"
#define NIMKit_ResourceBundleName                          @"NIMKitResource.bundle"

#define NIMKit_EmojiCatalog                                @"default"
#define NIMKit_EmojiPath                                   @"Emoji"
#define NIMKit_ChartletChartletCatalogPath                 @"Chartlet"
#define NIMKit_ChartletChartletCatalogContentPath          @"content"
#define NIMKit_ChartletChartletCatalogIconPath             @"icon"
#define NIMKit_ChartletChartletCatalogIconsSuffixNormal    @"normal"
#define NIMKit_ChartletChartletCatalogIconsSuffixHighLight @"highlighted"

#define NIMKit_EmojiLeftMargin      8
#define NIMKit_EmojiRightMargin     8
#define NIMKit_EmojiTopMargin       14
#define NIMKit_DeleteIconWidth      43.0
#define NIMKit_DeleteIconHeight     43.0
#define NIMKit_EmojCellHeight       46.0
#define NIMKit_EmojImageHeight      43.0
#define NIMKit_EmojImageWidth       43.0
#define NIMKit_EmojRows             3

//貼圖
#define NIMKit_PicCellHeight        76.0
#define NIMKit_PicImageHeight       70.f
#define NIMKit_PicImageWidth        70.f
#define NIMKit_PicRows              2

#define NIMKit_UIColorFromRGBA(rgbValue, alphaValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]

#define NIMKit_UIColorFromRGB(rgbValue) NIMKit_UIColorFromRGBA(rgbValue, 1.0)


#define InputViewTopHeight       46
#define InputViewBottomHeight    216
#define InputMaxLength           1000
#define InputPlaceHolder         @"請輸入消息"

#endif

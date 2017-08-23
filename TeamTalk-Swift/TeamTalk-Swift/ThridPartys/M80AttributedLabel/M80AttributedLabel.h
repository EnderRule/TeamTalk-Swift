//
//  M80AttributedLabel.h
//  M80AttributedLabel
//
//  Created by amao on 13-9-1.
//  Copyright (c) 2013年 www.xiangwangfeng.com. All rights reserved.
//

#import "M80AttributedLabelDefines.h"
#import "NSMutableAttributedString+M80.h"

NS_ASSUME_NONNULL_BEGIN

@class M80AttributedLabelURL;

@interface M80AttributedLabel : UIView
@property (nonatomic,weak,nullable)     id<M80AttributedLabelDelegate> delegate;
@property (nonatomic,strong,nullable)    UIFont *font;                          //字體
@property (nonatomic,strong,nullable)    UIColor *textColor;                    //文字顏色
@property (nonatomic,strong,nullable)    UIColor *highlightColor;               //鏈接點擊時背景高亮色
@property (nonatomic,strong,nullable)    UIColor *linkColor;                    //鏈接色
@property (nonatomic,strong,nullable)    UIColor *shadowColor;                  //陰影顏色
@property (nonatomic,assign)            CGSize  shadowOffset;                   //陰影offset
@property (nonatomic,assign)            CGFloat shadowBlur;                     //陰影半徑
@property (nonatomic,assign)            BOOL    underLineForLink;               //鏈接是否帶下劃線
@property (nonatomic,assign)            BOOL    autoDetectLinks;                //自動檢測
@property (nonatomic,assign)            NSInteger   numberOfLines;              //行數
@property (nonatomic,assign)            CTTextAlignment textAlignment;          //文字排版樣式
@property (nonatomic,assign)            CTLineBreakMode lineBreakMode;          //LineBreakMode
@property (nonatomic,assign)            CGFloat lineSpacing;                    //行間距
@property (nonatomic,assign)            CGFloat paragraphSpacing;               //段間距
@property (nonatomic,copy,nullable)     NSString *text;                         //普通文本
@property (nonatomic,copy,nullable)     NSAttributedString *attributedText;     //屬性文本



//添加文本
- (void)appendText:(NSString *)text;
- (void)appendAttributedText:(NSAttributedString *)attributedText;

//圖片
- (void)appendImage:(UIImage *)image;
- (void)appendImage:(UIImage *)image
            maxSize:(CGSize)maxSize;
- (void)appendImage:(UIImage *)image
            maxSize:(CGSize)maxSize
             margin:(UIEdgeInsets)margin;
- (void)appendImage:(UIImage *)image
            maxSize:(CGSize)maxSize
             margin:(UIEdgeInsets)margin
          alignment:(M80ImageAlignment)alignment;

//UI控件
- (void)appendView:(UIView *)view;
- (void)appendView:(UIView *)view
            margin:(UIEdgeInsets)margin;
- (void)appendView:(UIView *)view
            margin:(UIEdgeInsets)margin
         alignment:(M80ImageAlignment)alignment;


//添加自定義鏈接
- (void)addCustomLink:(id)linkData
             forRange:(NSRange)range;

- (void)addCustomLink:(id)linkData
             forRange:(NSRange)range
            linkColor:(UIColor *)color;


//大小
- (CGSize)sizeThatFits:(CGSize)size;

//設置全局的自定義Link檢測Block(詳見M80AttributedLabelURL)
+ (void)setCustomDetectMethod:(nullable M80CustomDetectLinkBlock)block;

@end

NS_ASSUME_NONNULL_END

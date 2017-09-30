//
//  NTESEmoticonManager
//  NIM
//
//  Created by amao on 7/2/14.
//  Copyright (c) 2014 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NIMInputEmoticon : NSObject
@property (nonatomic,strong)    NSString    *emoticonID;
@property (nonatomic,strong)    NSString    *tag;
@property (nonatomic,strong)    NSString    *filename;
@end

@interface NIMInputEmoticonLayout : NSObject
@property (nonatomic, assign) NSInteger rows;               //行數
@property (nonatomic, assign) NSInteger columes;            //列數
@property (nonatomic, assign) NSInteger itemCountInPage;    //每頁顯示幾項
@property (nonatomic, assign) CGFloat   cellWidth;          //單個單元格寬
@property (nonatomic, assign) CGFloat   cellHeight;         //單個單元格高
@property (nonatomic, assign) CGFloat   imageWidth;         //顯示圖片的寬
@property (nonatomic, assign) CGFloat   imageHeight;        //顯示圖片的高
@property (nonatomic, assign) BOOL      emoji;

- (id)initEmojiLayout:(CGFloat)width;

- (id)initCharletLayout:(CGFloat)width;

@end

@interface NIMInputEmoticonCatalog : NSObject
@property (nonatomic,strong)    NIMInputEmoticonLayout *layout;
@property (nonatomic,strong)    NSString        *catalogID;
@property (nonatomic,strong)    NSString        *title;
@property (nonatomic,strong)    NSDictionary    *id2Emoticons;
@property (nonatomic,strong)    NSDictionary    *tag2Emoticons;
@property (nonatomic,strong)    NSArray         *emoticons;
@property (nonatomic,strong)    NSString        *icon;             //圖標
@property (nonatomic,strong)    NSString        *iconPressed;      //小圖標按下效果
@property (nonatomic,assign)    NSInteger       pagesCount;        //分頁數
@end

@interface NIMInputEmoticonManager : NSObject
+ (instancetype)sharedManager;

- (NIMInputEmoticonCatalog *)emoticonCatalog:(NSString *)catalogID;
- (NIMInputEmoticon *)emoticonByTag:(NSString *)tag;
- (NIMInputEmoticon *)emoticonByID:(NSString *)emoticonID;
- (NIMInputEmoticon *)emoticonByCatalogID:(NSString *)catalogID
                           emoticonID:(NSString *)emoticonID;

- (NSArray *)loadChartletEmoticonCatalog;
@end

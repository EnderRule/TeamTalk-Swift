//
//  TZImageCropManager.h
//  TZImagePickerController
//
//  Created by 譚真 on 2016/12/5.
//  Copyright c 2016年 譚真. All rights reserved.
//  圖片裁剪管理類

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TZImageCropManager : NSObject

/// 裁剪框背景的處理
+ (void)overlayClippingWithView:(UIView *)view cropRect:(CGRect)cropRect containerView:(UIView *)containerView needCircleCrop:(BOOL)needCircleCrop;

/*
 1.7.2 為了解決多位同學對於圖片裁剪的需求，我這兩天有空便在研究圖片裁剪
 幸好有tuyou的PhotoTweaks庫做參考，裁剪的功能實現起來簡單許多
 該方法和其內部引用的方法基本來自於tuyou的PhotoTweaks庫，我做了稍許刪減和修改
 感謝tuyou同學在github開源了優秀的裁剪庫PhotoTweaks，表示感謝
 PhotoTweaks庫的github鏈接：https://github.com/itouch2/PhotoTweaks
 */
/// 獲得裁剪後的圖片
+ (UIImage *)cropImageView:(UIImageView *)imageView toRect:(CGRect)rect zoomScale:(double)zoomScale containerView:(UIView *)containerView;

/// 獲取圓形圖片
+ (UIImage *)circularClipImage:(UIImage *)image;

@end


/// 該分類的代碼來自SDWebImage:https://github.com/rs/SDWebImage
/// 為了防止衝突，我將分類名字和方法名字做了修改
@interface UIImage (TZGif)

+ (UIImage *)sd_tz_animatedGIFWithData:(NSData *)data;

@end

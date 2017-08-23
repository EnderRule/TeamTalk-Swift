//
//  TZPhotoPreviewController.h
//  TZImagePickerController
//
//  Created by 譚真 on 15/12/24.
//  Copyright c 2015年 譚真. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TZPhotoPreviewController : UIViewController

@property (nonatomic, strong) NSMutableArray *models;                  ///< All photo models / 所有圖片模型數組
@property (nonatomic, strong) NSMutableArray *photos;                  ///< All photos  / 所有圖片數組
@property (nonatomic, assign) NSInteger currentIndex;           ///< Index of the photo user click / 用戶點擊的圖片的索引
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;       ///< If YES,return original photo / 是否返回原圖
@property (nonatomic, assign) BOOL isCropImage;

/// Return the new selected photos / 返回最新的選中圖片數組
@property (nonatomic, copy) void (^backButtonClickBlock)(BOOL isSelectOriginalPhoto);
@property (nonatomic, copy) void (^doneButtonClickBlock)(BOOL isSelectOriginalPhoto);
@property (nonatomic, copy) void (^doneButtonClickBlockCropMode)(UIImage *cropedImage,id asset);
@property (nonatomic, copy) void (^doneButtonClickBlockWithPreviewType)(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto);

@end

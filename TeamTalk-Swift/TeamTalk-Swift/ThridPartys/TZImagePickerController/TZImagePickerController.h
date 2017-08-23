//
//  TZImagePickerController.h
//  TZImagePickerController
//
//  Created by 譚真 on 15/12/24.
//  Copyright c 2015年 譚真. All rights reserved.
//  version 1.7.8 - 2016.12.20

/*
 經過測試，比起xib的方式，把TZAssetCell改用純代碼的方式來寫，滑動幀數明顯提高了（約提高10幀左右）
 
 最初發現這個問題並修復的是@小魚周凌宇同學，她的博客地址: http://zhoulingyu.com/
 表示感謝~
 
 原來xib確實會導致性能問題啊...大家也要注意了...
 */

#import <UIKit/UIKit.h>
#import "TZAssetModel.h"
#import "NSBundle+TZImagePicker.h"

#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)

@protocol TZImagePickerControllerDelegate;
@interface TZImagePickerController : UINavigationController

/// Use this init method / 用這個初始化方法
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<TZImagePickerControllerDelegate>)delegate;
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<TZImagePickerControllerDelegate>)delegate;
- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<TZImagePickerControllerDelegate>)delegate pushPhotoPickerVc:(BOOL)pushPhotoPickerVc;
/// This init method just for previewing photos / 用這個初始化方法以預覽圖片
- (instancetype)initWithSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index;
/// This init method for crop photo / 用這個初始化方法以裁剪圖片
- (instancetype)initCropTypeWithAsset:(id)asset photo:(UIImage *)photo completion:(void (^)(UIImage *cropImage,id asset))completion;

/// Default is 9 / 默認最大可選9張圖片
@property (nonatomic, assign) NSInteger maxImagesCount;

/// The minimum count photos user must pick, Default is 0
/// 最小照片必選張數,默認是0
@property (nonatomic, assign) NSInteger minImagesCount;

/// Always enale the done button, not require minimum 1 photo be picked
/// 讓完成按鈕一直可以點擊，無須最少選擇一張圖片
@property (nonatomic, assign) BOOL alwaysEnableDoneBtn;

/// Sort photos ascending by modificationDate，Default is YES
/// 對照片排序，按修改時間升序，默認是YES。如果設置為NO,最新的照片會顯示在最前面，內部的拍照按鈕會排在第一個
@property (nonatomic, assign) BOOL sortAscendingByModificationDate;

/// Default is 828px / 默認828像素寬
@property (nonatomic, assign) CGFloat photoWidth;

/// Default is 600px / 默認600像素寬
@property (nonatomic, assign) CGFloat photoPreviewMaxWidth;

/// Default is 15, While fetching photo, HUD will dismiss automatic if timeout;
/// 超時時間，默認為15秒，當取圖片時間超過15秒還沒有取成功時，會自動dismiss HUD；
@property (nonatomic, assign) NSInteger timeout;

/// Default is YES, if set NO, the original photo button will hide. user can't picking original photo.
/// 默認為YES，如果設置為NO,原圖按鈕將隱藏，用戶不能選擇發送原圖
@property (nonatomic, assign) BOOL allowPickingOriginalPhoto;

/// Default is YES, if set NO, user can't picking video.
/// 默認為YES，如果設置為NO,用戶將不能選擇視頻
@property (nonatomic, assign) BOOL allowPickingVideo;

/// Default is NO, if set YES, user can picking gif image.
/// 默認為NO，如果設置為YES,用戶可以選擇gif圖片
@property (nonatomic, assign) BOOL allowPickingGif;

/// Default is YES, if set NO, user can't picking image.
/// 默認為YES，如果設置為NO,用戶將不能選擇發送圖片
@property(nonatomic, assign) BOOL allowPickingImage;

/// Default is YES, if set NO, user can't take picture.
/// 默認為YES，如果設置為NO,拍照按鈕將隱藏,用戶將不能選擇照片
@property(nonatomic, assign) BOOL allowTakePicture;

/// Default is YES, if set NO, user can't preview photo.
/// 默認為YES，如果設置為NO,預覽按鈕將隱藏,用戶將不能去預覽照片
@property (nonatomic, assign) BOOL allowPreview;

/// Default is YES, if set NO, the picker don't dismiss itself.
/// 默認為YES，如果設置為NO, 選擇器將不會自己dismiss
@property(nonatomic, assign) BOOL autoDismiss;

/// The photos user have selected
/// 用戶選中過的圖片數組
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, strong) NSMutableArray<TZAssetModel *> *selectedModels;

/// Minimum selectable photo width, Default is 0
/// 最小可選中的圖片寬度，默認是0，小於這個寬度的圖片不可選中
@property (nonatomic, assign) NSInteger minPhotoWidthSelectable;
@property (nonatomic, assign) NSInteger minPhotoHeightSelectable;
/// Hide the photo what can not be selected, Default is NO
/// 隱藏不可以選中的圖片，默認是NO，不推薦將其設置為YES
@property (nonatomic, assign) BOOL hideWhenCanNotSelect;

/// Single selection mode, valid when maxImagesCount = 1
/// 單選模式,maxImagesCount為1時才生效
@property (nonatomic, assign) BOOL showSelectBtn;   ///< 在單選模式下，照片列表頁中，顯示選擇按鈕,默認為NO
@property (nonatomic, assign) BOOL allowCrop;       ///< 允許裁剪,默認為YES，showSelectBtn為NO才生效
@property (nonatomic, assign) CGRect cropRect;      ///< 裁剪框的尺寸
@property (nonatomic, assign) BOOL needCircleCrop;  ///< 需要圓形裁剪框
@property (nonatomic, assign) NSInteger circleCropRadius;  ///< 圓形裁剪框半徑大小
@property (nonatomic, copy) void (^cropViewSettingBlock)(UIView *cropView);     ///< 自定義裁剪框的其他屬性

- (void)showAlertWithTitle:(NSString *)title;
- (void)showProgressHUD;
- (void)hideProgressHUD;
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;

@property (nonatomic, copy) NSString *takePictureImageName;
@property (nonatomic, copy) NSString *photoSelImageName;
@property (nonatomic, copy) NSString *photoDefImageName;
@property (nonatomic, copy) NSString *photoOriginSelImageName;
@property (nonatomic, copy) NSString *photoOriginDefImageName;
@property (nonatomic, copy) NSString *photoPreviewOriginDefImageName;
@property (nonatomic, copy) NSString *photoNumberIconImageName;

/// Appearance / 外觀顏色 + 按鈕文字
@property (nonatomic, strong) UIColor *oKButtonTitleColorNormal;
@property (nonatomic, strong) UIColor *oKButtonTitleColorDisabled;
@property (nonatomic, strong) UIColor *barItemTextColor;
@property (nonatomic, strong) UIFont *barItemTextFont;

@property (nonatomic, copy) NSString *doneBtnTitleStr;
@property (nonatomic, copy) NSString *cancelBtnTitleStr;
@property (nonatomic, copy) NSString *previewBtnTitleStr;
@property (nonatomic, copy) NSString *fullImageBtnTitleStr;
@property (nonatomic, copy) NSString *settingBtnTitleStr;
@property (nonatomic, copy) NSString *processHintStr;

/// Public Method
- (void)cancelButtonClick;

// The picker should dismiss itself; when it dismissed these handle will be called.
// You can also set autoDismiss to NO, then the picker don't dismiss itself.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[TZImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.
// 這個照片選擇器會自己dismiss，當選擇器dismiss的時候，會執行下面的handle
// 你也可以設置autoDismiss屬性為NO，選擇器就不會自己dismis了
// 如果isSelectOriginalPhoto為YES，表明用戶選擇了原圖
// 你可以通過一個asset獲得原圖，通過這個方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos數組裡的UIImage對象，默認是828像素寬，你可以通過設置photoWidth屬性的值來改變它
@property (nonatomic, copy) void (^didFinishPickingPhotosHandle)(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto);
@property (nonatomic, copy) void (^didFinishPickingPhotosWithInfosHandle)(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto,NSArray<NSDictionary *> *infos);
@property (nonatomic, copy) void (^imagePickerControllerDidCancelHandle)();

// If user picking a video, this handle will be called.
// If system version > iOS8,asset is kind of PHAsset class, else is ALAsset class.
// 如果用戶選擇了一個視頻，下面的handle會被執行
// 如果系統版本大於iOS8，asset是PHAsset類的對象，否則是ALAsset類的對象
@property (nonatomic, copy) void (^didFinishPickingVideoHandle)(UIImage *coverImage,id asset);

// If user picking a gif image, this callback will be called.
// 如果用戶選擇了一個gif圖片，下面的handle會被執行
@property (nonatomic, copy) void (^didFinishPickingGifImageHandle)(UIImage *animatedImage,id sourceAssets);

@property (nonatomic, weak) id<TZImagePickerControllerDelegate> pickerDelegate;

@end


@protocol TZImagePickerControllerDelegate <NSObject>
@optional
// The picker should dismiss itself; when it dismissed these handle will be called.
// You can also set autoDismiss to NO, then the picker don't dismiss itself.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[TZImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.
// 這個照片選擇器會自己dismiss，當選擇器dismiss的時候，會執行下面的handle
// 你也可以設置autoDismiss屬性為NO，選擇器就不會自己dismis了
// 如果isSelectOriginalPhoto為YES，表明用戶選擇了原圖
// 你可以通過一個asset獲得原圖，通過這個方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos數組裡的UIImage對象，默認是828像素寬，你可以通過設置photoWidth屬性的值來改變它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto;
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos;
- (void)imagePickerControllerDidCancel:(TZImagePickerController *)picker __attribute__((deprecated("Use -tz_imagePickerControllerDidCancel:.")));
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker;

// If user picking a video, this callback will be called.
// If system version > iOS8,asset is kind of PHAsset class, else is ALAsset class.
// 如果用戶選擇了一個視頻，下面的handle會被執行
// 如果系統版本大於iOS8，asset是PHAsset類的對象，否則是ALAsset類的對象
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset;

// If user picking a gif image, this callback will be called.
// 如果用戶選擇了一個gif圖片，下面的handle會被執行
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(id)asset;
@end


@interface TZAlbumPickerController : UIViewController
@property (nonatomic, assign) NSInteger columnNumber;
@end


@interface UIImage (MyBundle)

+ (UIImage *)imageNamedFromMyBundle:(NSString *)name;

@end


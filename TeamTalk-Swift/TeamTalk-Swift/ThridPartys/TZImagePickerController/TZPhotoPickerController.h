//
//  TZPhotoPickerController.h
//  TZImagePickerController
//
//  Created by 譚真 on 15/12/24.
//  Copyright c 2015年 譚真. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TZAlbumModel;
@interface TZPhotoPickerController : UIViewController

@property (nonatomic, assign) BOOL isFirstAppear;
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, strong) TZAlbumModel *model;

@property (nonatomic, copy) void (^backButtonClickHandle)(TZAlbumModel *model);

@end


@interface TZCollectionView : UICollectionView

@end

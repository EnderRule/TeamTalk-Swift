//
//  NIMPageView.h
//  NIMKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NIMPageView;

@protocol NIMPageViewDataSource <NSObject>
- (NSInteger)numberOfPages: (NIMPageView *)pageView;
- (UIView *)pageView: (NIMPageView *)pageView viewInPage: (NSInteger)index;
@end

@protocol NIMPageViewDelegate <NSObject>
@optional
- (void)pageViewScrollEnd: (NIMPageView *)pageView
             currentIndex: (NSInteger)index
               totolPages: (NSInteger)pages;

- (void)pageViewDidScroll: (NIMPageView *)pageView;
- (BOOL)needScrollAnimation;
@end


@interface NIMPageView : UIView<UIScrollViewDelegate>
@property (nonatomic,strong)    UIScrollView   *scrollView;
@property (nonatomic,weak)    id<NIMPageViewDataSource>  dataSource;
@property (nonatomic,weak)    id<NIMPageViewDelegate>    pageViewDelegate;
- (void)scrollToPage: (NSInteger)pages;
- (void)reloadData;
- (UIView *)viewAtIndex: (NSInteger)index;
- (NSInteger)currentPage;


//旋轉相關方法,這兩個方法必須配對調用,否則會有問題
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration;

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration;
@end

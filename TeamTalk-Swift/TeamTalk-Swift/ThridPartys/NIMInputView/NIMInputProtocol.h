//
//  NIMInputProtocol.h
//  NIMKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NIMMediaItem;


@protocol NIMInputActionDelegate <NSObject>

@optional
- (BOOL)onTapMediaItem:(NIMMediaItem *)item;

- (void)onTextChanged:(id)sender;

- (void)onSendText:(NSString *)text
           atUsers:(NSArray *)atUsers;

- (void)onSelectChartlet:(NSString *)chartletId
                 catalog:(NSString *)catalogId;


- (void)onCancelRecording;

- (void)onStopRecording;

- (void)onStartRecording;

- (void)onInputViewActive:(BOOL)active;

- (BOOL)onAtStart;   //返回YES 則表示 啟用 @ 某人，返回NO 則只輸入 @ 符號
@end


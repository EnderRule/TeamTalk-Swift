//
//  DDChattingModule.h
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-28.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTTSessionEntity;
@class MTTUserEntity;

#define DD_PAGE_ITEM_COUNT                  20


@class DDCommodity;
@class MTTMessageEntity;
typedef void(^DDChatLoadMoreHistoryCompletion)(NSUInteger addcount, NSError* error);

@interface ChattingModule : NSObject

@property (strong,nonatomic)MTTSessionEntity *sessionEntity;
@property(strong)NSMutableArray *ids ;
@property (strong)NSMutableArray* showingMessages;
@property (assign) NSInteger isGroup;
/**
 *  加载历史消息接口，这里会适时插入时间
 *
 *  @param completion 加载完成
 */
- (void)loadMoreHistoryCompletion:(DDChatLoadMoreHistoryCompletion)completion;
- (void)loadAllHistoryCompletion:(MTTMessageEntity*)message Completion:(DDChatLoadMoreHistoryCompletion)completion;

- (void)addPrompt:(NSString*)prompt;
- (void)addShowMessage:(MTTMessageEntity*)message;
- (void)addShowMessages:(NSArray<MTTMessageEntity *> *)messages;
- (void)deleteShowMessage:(MTTMessageEntity *)message;

- (void)updateSessionUpdateTime:(NSUInteger)time;


-(void)loadHisToryMessageFromServer:(NSUInteger)FromMsgID loadCount:(NSUInteger)count Completion:(DDChatLoadMoreHistoryCompletion)completion;
-(void)loadHostoryMessageFromServer:(NSUInteger)FromMsgID Completion:(DDChatLoadMoreHistoryCompletion)completion;

-(void)getNewMsg:(DDChatLoadMoreHistoryCompletion)completion;
@end


@interface DDPromptEntity : NSObject
@property(nonatomic,retain)NSString* message;

@end

//
//  DDChattingModule.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-28.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "ChattingModule.h"
#import "MTTDatabaseUtil.h"


#import "NSDate+DDAddition.h"
#import "DDUserModule.h"

#import "DDMessageModule.h"

#import <math.h>

#import "DDClientState.h"
#import "SDWebImageManager.h"
#import "SDImageCache.h"
#import "MTTUtil.h"

#import "TeamTalk_Swift-Swift.h"


static NSUInteger const showPromptGap = 300;
@interface ChattingModule(privateAPI)
- (NSUInteger)p_getMessageCount;
- (void)p_addHistoryMessages:(NSArray*)messages Completion:(DDChatLoadMoreHistoryCompletion)completion;

@end

@implementation ChattingModule
{
    //只是用来获取cell的高度的
    
    NSUInteger _earliestDate;
    NSUInteger _lastestDate;
    
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.showingMessages = [[NSMutableArray alloc] init];
        self.ids = [NSMutableArray new];
    }
    return self;
}

- (void)setMTTSessionEntity:(MTTSessionEntity *)MTTSessionEntity
{
    self.SessionEntity = MTTSessionEntity;
    
    self.showingMessages = nil;
    self.showingMessages = [[NSMutableArray alloc] init];
}
-(void)getNewMsg:(DDChatLoadMoreHistoryCompletion)completion
{
    [[DDMessageModule shareInstance] getMessageFromServer:0 currentSession:self.SessionEntity count:20 Block:^(NSMutableArray *response, NSError *error) {
        //[self p_addHistoryMessages:response Completion:completion];
        NSUInteger msgID = [[response valueForKeyPath:@"@max.msgID"] integerValue];
        if ( msgID !=0) {
            if (response) {
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"msgTime" ascending:YES];
                [response sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                [[MTTDatabaseUtil instance] insertMessages:response success:^{
                    MsgReadACKAPI* readACK = [[MsgReadACKAPI alloc] init];
                    if(msgID){
                        [readACK requestWithObject:@[self.SessionEntity.sessionID,@(msgID),@(self.SessionEntity.sessionType)] Completion:nil];
                    }
                } failure:^(NSString *errorDescripe) {
                    
                }];
                [response enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [self addShowMessage:obj];
                }];
                completion([response count],error);
                
            }
            
            
        }else{
            completion(0,error);
        }
        
    }];
}
-(void)loadHisToryMessageFromServer:(NSUInteger)FromMsgID loadCount:(NSUInteger)count Completion:(DDChatLoadMoreHistoryCompletion)completion
{
    if (self.SessionEntity) {
        if (FromMsgID !=1) {
            [[DDMessageModule shareInstance] getMessageFromServer:FromMsgID currentSession:self.SessionEntity count:count Block:^(NSArray *response, NSError *error) {
                //[self p_addHistoryMessages:response Completion:completion];
                NSUInteger msgID = [[response valueForKeyPath:@"@max.msgID"] integerValue];
                if ( msgID !=0) {
                    if (response) {
                        [[MTTDatabaseUtil instance] insertMessages:response success:^{
                            MsgReadACKAPI* readACK = [[MsgReadACKAPI alloc] init];
                            [readACK requestWithObject:@[self.SessionEntity.sessionID,@(msgID),@(self.SessionEntity.sessionType)] Completion:nil];
                            
                        } failure:^(NSString *errorDescripe) {
                            
                        }];
                        NSUInteger count = [self p_getMessageCount];
                        [[MTTDatabaseUtil instance] loadMessageForSessionID:self.SessionEntity.sessionID pageCount:DD_PAGE_ITEM_COUNT index:count completion:^(NSArray *messages, NSError *error) {
                            [self p_addHistoryMessages:messages Completion:completion];
                            completion([response count],error);
                        }];
                        
                    }
                    
                    
                }else{
                    completion(0,error);
                }
                
            }];
        }else{
            completion(0,nil);
        }
        
    }
}
-(void)loadHostoryMessageFromServer:(NSUInteger)FromMsgID Completion:(DDChatLoadMoreHistoryCompletion)completion{
    [self loadHisToryMessageFromServer:FromMsgID loadCount:19 Completion:completion];
}

- (void)loadMoreHistoryCompletion:(DDChatLoadMoreHistoryCompletion)completion
{
    
    NSUInteger count = [self p_getMessageCount];
    
    [[MTTDatabaseUtil instance] loadMessageForSessionID:self.SessionEntity.sessionID pageCount:DD_PAGE_ITEM_COUNT index:count completion:^(NSArray *messages, NSError *error) {
        //after loading finish ,then add to messages
        if ([DDClientState shareInstance].networkState == DDNetWorkDisconnect) {
            [self p_addHistoryMessages:messages Completion:completion];
        }else{
            if ([messages count] !=0) {
                
                BOOL isHaveMissMsg = [self p_isHaveMissMsg:messages];
                if (isHaveMissMsg || ([self getMiniMsgId] - [self getMaxMsgId:messages] !=0)) {
                    
                    [self loadHostoryMessageFromServer:[self getMiniMsgId] Completion:^(NSUInteger addcount, NSError *error) {
                        if (addcount) {
                            completion(addcount,error);
                        }else{
                            [self p_addHistoryMessages:messages Completion:completion];
                        }
                    }];
                }else{
                    //检查消息是否连续
                    [self p_addHistoryMessages:messages Completion:completion];
                    //                [self checkMsgList:^(NSUInteger addcount, NSError *error) {
                    //                    completion(addcount,error);
                    //                    if (!addcount) {
                    //                               [self p_addHistoryMessages:messages Completion:completion];
                    //                    }
                    //                }];
                    
                }
                
            }else{
                //数据库中已获取不到消息
                //拿出当前最小的msgid去服务端取
                [self loadHostoryMessageFromServer:[self getMiniMsgId] Completion:^(NSUInteger addcount, NSError *error) {
                    completion(addcount,error);
                }];
            }
            
            
        }
        
    }];
}
- (void)loadAllHistoryCompletion:(MTTMessageEntity*)message Completion:(DDChatLoadMoreHistoryCompletion)completion
{
    [[MTTDatabaseUtil instance] loadMessageForSessionID:self.SessionEntity.sessionID afterMessage:message completion:^(NSArray *messages, NSError *error) {
        [self p_addHistoryMessages:messages Completion:completion];
    }];
}
-(NSUInteger )getMiniMsgId
{
    if ([self.showingMessages count] == 0) {
        return self.SessionEntity.lastMsgID;
    }
    __block NSInteger minMsgID =[self getMaxMsgId:self.showingMessages];
    
    [self.showingMessages enumerateObjectsUsingBlock:^(MTTMessageEntity * obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[MTTMessageEntity class]]) {
            if(obj.msgID <minMsgID)
            {
                minMsgID = obj.msgID;
            }
        }
    }];
    return minMsgID;
}

- (void)addPrompt:(NSString*)promptContent
{
    DDPromptEntity* prompt = [[DDPromptEntity alloc] init];
    prompt.message = promptContent;
    [self.showingMessages addObject:prompt];
}

- (void)addShowMessage:(MTTMessageEntity*)message
{
    if (![self.ids containsObject:@(message.msgID)]) {
        if (message.msgTime - _lastestDate > showPromptGap)
        {
            _lastestDate = message.msgTime;
            DDPromptEntity* prompt = [[DDPromptEntity alloc] init];
            NSDate* date = [NSDate dateWithTimeIntervalSince1970:message.msgTime];
            prompt.message = [date promptDateString];
            [self.showingMessages addObject:prompt];
            
        }
        NSArray *array = [[self class] p_spliteMessage:message];
        [array enumerateObjectsUsingBlock:^(MTTMessageEntity* obj, NSUInteger idx, BOOL *stop) {
            [[self mutableArrayValueForKeyPath:@"showingMessages"] addObject:obj];
        }];
    }
}

- (void)addShowMessages:(NSArray*)messages
{
    
    [[self mutableArrayValueForKeyPath:@"showingMessages"] addObjectsFromArray:messages];
}
-(void)getCurrentUser:(void(^)(MTTUserEntity *))block
{
    [[DDUserModule shareInstance] getUserForUserID:self.SessionEntity.sessionID  Block:^(MTTUserEntity *user) {
        block(user);
    }];
    
}


- (void)updateSessionUpdateTime:(NSUInteger)time
{
    [self.SessionEntity updateWithUpdateTime:time];
    _lastestDate = time;
}


#pragma mark -
#pragma mark PrivateAPI
- (NSUInteger)p_getMessageCount
{
    __block NSUInteger count = 0;
    [self.showingMessages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[MTTMessageEntity class]])
        {
            count ++;
        }
    }];
    return count;
}

- (void)p_addHistoryMessages:(NSArray*)messages Completion:(DDChatLoadMoreHistoryCompletion)completion
{
    
    __block NSUInteger tempEarliestDate = [[messages valueForKeyPath:@"@min.msgTime"] integerValue];
    __block NSUInteger tempLasteestDate = 0;
    NSUInteger itemCount = [self.showingMessages count];
    NSMutableArray *tmp = [NSMutableArray arrayWithArray:messages];
    //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"msgTime" ascending:YES];
    //    [tmp sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSMutableArray* tempMessages = [[NSMutableArray alloc] init];
    for (NSInteger index = [tmp count] - 1; index >= 0;index --)
    {
        
        MTTMessageEntity* message = tmp[index];
        
        
        if ([self.ids containsObject:@(message.msgID)]) {
            continue;
        }
        //            if (index == [tmp count] - 1)
        //            {
        //                tempEarliestDate = message.msgTime;
        //
        //            }
        if (message.msgTime - tempLasteestDate > showPromptGap)
        {
            DDPromptEntity* prompt = [[DDPromptEntity alloc] init];
            NSDate* date = [NSDate dateWithTimeIntervalSince1970:message.msgTime];
            prompt.message = [date promptDateString];
            [tempMessages addObject:prompt];
        }
        tempLasteestDate = message.msgTime;
        NSArray *array = [[self class] p_spliteMessage:message];
        [array enumerateObjectsUsingBlock:^(MTTMessageEntity * obj, NSUInteger idx, BOOL *stop) {
            
            [self.ids addObject:@(message.msgID)];
            [tempMessages addObject:obj];
        }];
    }
    
    if ([self.showingMessages count] == 0)
    {
        [[self mutableArrayValueForKeyPath:@"showingMessages"] addObjectsFromArray:tempMessages];
        _earliestDate = tempEarliestDate;
        _lastestDate = tempLasteestDate;
    }
    else
    {
        [self.showingMessages insertObjects:tempMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [tempMessages count])]];
        _earliestDate = tempEarliestDate;
    }
    NSUInteger newItemCount = [self.showingMessages count];
    completion(newItemCount - itemCount,nil);
}

+ (NSArray*)p_spliteMessage:(MTTMessageEntity*)message
{
    message.msgContent = [message.msgContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableArray* messageContentArray = [[NSMutableArray alloc] init];
    
    if ( [ message.msgContent rangeOfString:DD_MESSAGE_IMAGE_PREFIX].length > 0)
    {
        NSString* messageContent = [message msgContent];
        if ([messageContent rangeOfString:DD_MESSAGE_IMAGE_PREFIX].length > 0 && [messageContent rangeOfString:MTTMessageEntity.DD_IMAGE_LOCAL_KEY].length > 0 && [messageContent rangeOfString:MTTMessageEntity.DD_IMAGE_URL_KEY].length > 0) {
            MTTMessageEntity* messageEntity = [[MTTMessageEntity alloc] initWithMsgID:(uint32_t)[DDMessageModule getMessageID] msgType:message.msgType msgTime:message.msgTime sessionID:message.sessionId senderID:message.senderId msgContent:messageContent toUserID:message.toUserID];
            messageEntity.msgContentType = DDMessageContentTypeImage;
            messageEntity.state = DDMessageStateSendSuccess;
        }else{
            
            NSArray* tempMessageContent = [messageContent componentsSeparatedByString:DD_MESSAGE_IMAGE_PREFIX];
            [tempMessageContent enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString* content = (NSString*)obj;
                if ([content length] > 0)
                {
                    NSRange suffixRange = [content rangeOfString:DD_MESSAGE_IMAGE_SUFFIX];
                    if (suffixRange.length > 0)
                    {
                        //是图片,再拆分
                        NSString* imageContent = [NSString stringWithFormat:@"%@%@",DD_MESSAGE_IMAGE_PREFIX,[content substringToIndex:suffixRange.location + suffixRange.length]];
                        MTTMessageEntity* messageEntity = [[MTTMessageEntity alloc] initWithMsgID:[DDMessageModule getMessageID] msgType:message.msgType msgTime:message.msgTime sessionID:message.sessionId senderID:message.senderId msgContent:imageContent toUserID:message.toUserID];
                        messageEntity.msgContentType = DDMessageContentTypeImage;
                        messageEntity.state = DDMessageStateSendSuccess;
                        [messageContentArray addObject:messageEntity];
                        
                        
                        NSString* secondComponent = [content substringFromIndex:suffixRange.location + suffixRange.length];
                        if (secondComponent.length > 0)
                        {
                            MTTMessageEntity* secondmessageEntity = [[MTTMessageEntity alloc] initWithMsgID:[DDMessageModule getMessageID] msgType:message.msgType msgTime:message.msgTime sessionID:message.sessionId senderID:message.senderId msgContent:secondComponent toUserID:message.toUserID];
                            secondmessageEntity.msgContentType = DDMessageContentTypeText;
                            secondmessageEntity.state = DDMessageStateSendSuccess;
                            [messageContentArray addObject:secondmessageEntity];
                        }
                    }
                    else
                    {
                        
                        MTTMessageEntity* messageEntity = [[MTTMessageEntity alloc] initWithMsgID:[DDMessageModule getMessageID] msgType:message.msgType msgTime:message.msgTime sessionID:message.sessionId senderID:message.senderId msgContent:content toUserID:message.toUserID];
                        messageEntity.state = DDMessageStateSendSuccess;
                        [messageContentArray addObject:messageEntity];
                    }
                }
            }];
        }
    }
    
    if ([messageContentArray count] == 0)
    {
        [messageContentArray addObject:message];
    }
    
    return messageContentArray;
    
}
-(NSInteger)getMaxMsgId:(NSArray *)array
{
    __block NSInteger maxMsgID =0;
    [array enumerateObjectsUsingBlock:^(MTTMessageEntity * obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[MTTMessageEntity class]]) {
            if (obj.msgID > maxMsgID && obj.msgID<LOCAL_MSG_BEGIN_ID) {
                maxMsgID =obj.msgID;
            }
        }
    }
     ];
    return maxMsgID;
}
- (BOOL)p_isHaveMissMsg:(NSArray*)messages
{
    
    __block NSInteger maxMsgID =[self getMaxMsgId:messages];
    __block NSInteger minMsgID =[self getMaxMsgId:messages];;
    [messages enumerateObjectsUsingBlock:^(MTTMessageEntity * obj, NSUInteger idx, BOOL *stop) {
        if (obj.msgID > maxMsgID && obj.msgID<LOCAL_MSG_BEGIN_ID) {
            //maxMsgID =obj.msgID;
        }else if(obj.msgID <minMsgID)
        {
            minMsgID = obj.msgID;
        }
    }];
    
    //   NSUInteger maxMsgID = [msgIds valueForKeyPath:@"@max"];
    //    NSUInteger minMsgID = [msgIds valueForKeyPath:@"@min"];
    
    NSUInteger diff = maxMsgID - minMsgID;
    if (diff != 19) {
        return YES;
    }
    return NO;
}

-(void)checkMsgList:(DDChatLoadMoreHistoryCompletion)completion
{
    NSMutableArray *tmp = [NSMutableArray arrayWithArray:self.showingMessages];
    [tmp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[DDPromptEntity class]]) {
            [tmp removeObject:obj];
        }else{
            MTTMessageEntity *msg = obj;
            if (msg.msgID>=LOCAL_MSG_BEGIN_ID) {
                [tmp removeObject:obj];
            }
        }
        
    }];
    
    [tmp enumerateObjectsUsingBlock:^(MTTMessageEntity *obj, NSUInteger idx, BOOL *stop) {
        if (idx +1 < [tmp count]) {
            MTTMessageEntity * msg = [tmp objectAtIndex:idx+1];
            if ((obj.msgID - msg.msgID) !=1) {
                [self loadHisToryMessageFromServer:MIN(obj.msgID, msg.msgID) loadCount:(obj.msgID - msg.msgID) Completion:^(NSUInteger addcount, NSError *error) {
                    completion(addcount,error);
                }];
            }
        }
        
    }];
}
@end

@implementation DDPromptEntity

@end

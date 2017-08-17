//
//  DDMessageModule.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-27.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDMessageModule.h"
#import "MTTDatabaseUtil.h"


#import "MTTAFNetworkingClient.h"

#import "RuntimeStatus.h"

#import "DDUserModule.h"

#import "DDGroupModule.h"

#import "MTTDDNotification.h"

#import "TeamTalk_Swift-Swift.h"


@interface DDMessageModule(){

    NSMutableDictionary* _unreadMessages;
}

@end

@implementation DDMessageModule

+ (instancetype)shareInstance
{
    static DDMessageModule* g_messageModule;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_messageModule = [[DDMessageModule alloc] init];
    });
    return g_messageModule;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        //注册收到消息API
        self.unreadMsgCount =0;
        _unreadMessages = [[NSMutableDictionary alloc] init];
        
        [self p_registerReceiveMessageAPI];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (NSUInteger )getMessageID
{
    NSInteger messageID = [[NSUserDefaults standardUserDefaults] integerForKey:@"msg_id"];
    if(messageID == 0)
    {
        messageID=LOCAL_MSG_BEGIN_ID;
    }else{
        messageID ++;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:messageID forKey:@"msg_id"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return messageID;
}


-(void)sendMsgRead:(MTTMessageEntity *)message
{
    MsgReadACKAPI* readACK = [[MsgReadACKAPI alloc] init];
    [readACK requestWithObject:@[message.sessionId,@(message.msgID),@(message.sessionType)] Completion:nil];
}


-(void)removeAllUnreadMessages{

    [_unreadMessages removeAllObjects];
}


- (NSUInteger)getUnreadMessgeCount
{
    __block NSUInteger count = 0;
    [_unreadMessages enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        count += [obj count];
    }];
    
    return count;
}


#pragma mark - privateAPI
- (void)p_registerReceiveMessageAPI
{
    ReceiveMessageAPI* receiveMessageAPI = [[ReceiveMessageAPI alloc] init];
    [receiveMessageAPI registerAPIInAPIScheduleReceiveData:^(MTTMessageEntity* object, NSError *error) {
        object.state=DDMessageStateSendSuccess;
        ReceiveMessageACKAPI *rmack = [[ReceiveMessageACKAPI alloc] init];
        [rmack requestWithObject:@[object.senderId,@(object.msgID),object.sessionId,@(object.sessionType)] Completion:^(id response, NSError *error) {
            
        }];
//        NSArray* messages = [self p_spliteMessage:object];
//        [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            [self p_saveReceivedMessage:obj];
//        }];
        if ([object isGroupMessage]) {
            MTTGroupEntity *group = [[DDGroupModule instance] getGroupByGId:object.sessionId];
            if (group.isShield == 1) {
                MsgReadACKAPI* readACK = [[MsgReadACKAPI alloc] init];
                [readACK requestWithObject:@[object.sessionId,@(object.msgID),@(object.sessionType)] Completion:nil];
            }
        }
        [[MTTDatabaseUtil instance] insertMessages:@[object] success:^{
            
        } failure:^(NSString *errorDescripe) {
            
        }];
        [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationReceiveMessage object:object];
    }];
    
}

-(void)getMessageFromServer:(NSInteger)fromMsgID currentSession:(MTTSessionEntity *)session count:(NSInteger)count Block:(void(^)(NSMutableArray *array, NSError *error))block
{
    GetMessageQueueAPI *getMessageQueue = [GetMessageQueueAPI new];
    [getMessageQueue requestWithObject:@[@(fromMsgID),@(count),@(session.sessionType),session.sessionID] Completion:^(NSMutableArray *response, NSError *error) {
        block(response,error);
        
    }];
    
}


- (NSArray*)p_spliteMessage:(MTTMessageEntity*)message
{
    NSMutableArray* messageContentArray = [[NSMutableArray alloc] init];
    if (message.msgContentType == DDMessageContentTypeImage || (message.msgContentType == DDMessageContentTypeText && [message.msgContent rangeOfString:DD_MESSAGE_IMAGE_PREFIX].length > 0))
    {
        NSString* messageContent = [message msgContent];
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
                    MTTMessageEntity* messageEntity = [[MTTMessageEntity alloc] initWithMsgID:(uint32_t)[DDMessageModule getMessageID] msgType:message.msgType msgTime:message.msgTime sessionID:message.sessionId senderID:message.senderId msgContent:imageContent toUserID:message.toUserID];
                    messageEntity.msgContentType = DDMessageContentTypeImage;
                    messageEntity.state = DDMessageStateSendSuccess;
                    [messageContentArray addObject:messageEntity];
                    
                    
                    NSString* secondComponent = [content substringFromIndex:suffixRange.location + suffixRange.length];
                    if (secondComponent.length > 0)
                    {
                        MTTMessageEntity* secondmessageEntity = [[MTTMessageEntity alloc] initWithMsgID:(uint32_t)[DDMessageModule getMessageID] msgType:message.msgType msgTime:message.msgTime sessionID:message.sessionId senderID:message.senderId msgContent:secondComponent toUserID:message.toUserID];
                        secondmessageEntity.msgContentType = DDMessageContentTypeText;
                        secondmessageEntity.state = DDMessageStateSendSuccess;
                        [messageContentArray addObject:secondmessageEntity];
                    }
                }
                else
                {
           
                    MTTMessageEntity* messageEntity = [[MTTMessageEntity alloc] initWithMsgID:(uint32_t)[DDMessageModule getMessageID] msgType:message.msgType msgTime:message.msgTime sessionID:message.sessionId senderID:message.senderId msgContent:content toUserID:message.toUserID];
                    messageEntity.msgContentType = DDMessageContentTypeText;
                    messageEntity.state = DDMessageStateSendSuccess;
                    [messageContentArray addObject:messageEntity];
                }
            }
        }];
    }
    if ([messageContentArray count] == 0)
    {
        [messageContentArray addObject:message];
    }
    return messageContentArray;
}

-(void)setApplicationUnreadMsgCount
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[self getUnreadMessgeCount]];
}

@end

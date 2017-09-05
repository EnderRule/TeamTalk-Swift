
//
//  DDMessageSendManager.m
//  Duoduo
//
//  Created by 独嘉 on 14-3-30.
//  Copyright (c) 2015年 MoguIM All rights reserved.
//

#import "DDMessageSendManager.h"
#import "DDUserModule.h"

#import "DDMessageModule.h"
#import "DDTcpClientManager.h"




#import "NSDictionary+JSON.h"
#import "UnAckMessageManager.h"


#import "NSData+Conversion.h"
#import "MTTDatabaseUtil.h"
#import "security.h"

#import "TeamTalk_Swift-Swift.h"

static uint32_t seqNo = 0;

@implementation DDMessageSendManager
{
    NSUInteger _uploadImageCount;
}
+ (instancetype)instance
{
    static DDMessageSendManager* g_messageSendManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_messageSendManager = [[DDMessageSendManager alloc] init];
    });
    return g_messageSendManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _uploadImageCount = 0;
        _waitToSendMessage = [[NSMutableArray alloc] init];
        _sendMessageSendQueue = dispatch_queue_create("com.mogujie.Duoduo.sendMessageSend", NULL);

    }
    return self;
}

- (void)sendMessage:(MTTMessageEntity *)message isGroup:(BOOL)isGroup Session:(MTTSessionEntity*)session completion:(DDSendMessageCompletion)completion Error:(void (^)(NSError *))block
{
    
    dispatch_async(self.sendMessageSendQueue, ^{
        uint32_t nowSeqNo = ++seqNo;
        message.seqNo=nowSeqNo;
        
        NSString* newContent = message.msgContent;
        if ([message isImageMessage]) {
            NSDictionary* dic = [NSDictionary initWithJsonString:message.msgContent];
            NSString* urlPath = dic[MTTMessageEntity.DD_IMAGE_URL_KEY];
            newContent=urlPath;
        }
        
        char* pOut;
        unsigned int** nOutLen = 0;
        const char *test =[newContent cStringUsingEncoding:NSUTF8StringEncoding];
        uint32_t nInLen  = (uint32_t)strlen(test);
        
        EncryptMsg(test, nInLen, &pOut, nOutLen);
        
        nOutLen = NULL;
        
        NSString *msg = [NSString stringWithCString:pOut encoding:NSUTF8StringEncoding];
        if (pOut){
            Free(pOut);
        }
        NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
        
        if(!message.msgID){
            return;
        }
        if ([message isImageMessage]) {
            session.lastMsg=@"[图片]";
        }else if ([message isVoiceMessage])
        {
            session.lastMsg=@"[语言]";
        }else
        {
            session.lastMsg=message.msgContent;
        }
        [[UnAckMessageManager instance] addMessageToUnAckQueue:message];

        
        NSArray* object = @[[HMLoginManager shared].currentUser.userId,session.sessionID,data,@(message.msgType),@(message.msgID)];
        SendMessageAPI* sendMessageAPI = [[SendMessageAPI alloc] init];
        [sendMessageAPI requestWithObject:object Completion:^(id response, NSError *error) {
            if (!error)
            {
//                DDLog(@"发送消息成功");
                [[MTTDatabaseUtil instance] deleteMesages:message completion:^(BOOL success){
                    
                }];
                
                [[UnAckMessageManager instance] removeMessageFromUnAckQueue:message];
                
                message.msgID=(uint32_t)[response[0] integerValue];
                message.state=DDMessageStateSendSuccess;
                session.lastMsgID=message.msgID;
                session.timeInterval=message.msgTime;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SentMessageSuccessfull" object:session];
                [[MTTDatabaseUtil instance] insertMessages:@[message] success:^{
                    
                } failure:^(NSString *errorDescripe) {
                    
                }];
                completion(message,nil);
                
                
            }
            else
            {
                message.state=DDMessageStateSendFailure;
                [[MTTDatabaseUtil instance] insertMessages:@[message] success:^{
                    
                } failure:^(NSString *errorDescripe) {
                    
                }];
                NSError* error = [NSError errorWithDomain:@"发送消息失败" code:0 userInfo:nil];
                block(error);
            }
        }];
        
    });
}

- (void)sendVoiceMessage:(NSData*)voice filePath:(NSString*)filePath forSessionID:(NSString*)sessionID isGroup:(BOOL)isGroup Message:(MTTMessageEntity *)msg Session:(MTTSessionEntity*)session completion:(DDSendMessageCompletion)completion
{
    dispatch_async(self.sendMessageSendQueue, ^{
        SendMessageAPI* sendVoiceMessageAPI = [[SendMessageAPI alloc] init];
        
        NSString* myUserID = [HMLoginManager shared].currentUser.userId;
        NSArray* object = @[myUserID,sessionID,voice,@(msg.msgType),@(0)];
       
        [sendVoiceMessageAPI requestWithObject:object Completion:^(id response, NSError *error) {
            if (!error)
            {
                NSLog(@"发送消息成功");
                [[MTTDatabaseUtil instance] deleteMesages:msg completion:^(BOOL success){
                    
                }];
                
                
                NSUInteger messageTime = [[NSDate date] timeIntervalSince1970];
                msg.msgTime=(uint32_t)messageTime;
                msg.msgID=(uint32_t)[response[0] integerValue];
                msg.state=DDMessageStateSendSuccess;
                session.lastMsg=@"[语音]";
                session.lastMsgID=msg.msgID;
                session.timeInterval=msg.msgTime;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SentMessageSuccessfull" object:session];
                [[MTTDatabaseUtil instance] insertMessages:@[msg] success:^{
                    
                } failure:^(NSString *errorDescripe) {
                    
                }];
                
                completion(msg,nil);
                
            }
            else
            {
                NSError* error = [NSError errorWithDomain:@"发送消息失败" code:0 userInfo:nil];
                completion(nil,error);
            }
        }];
        
    });
}

@end

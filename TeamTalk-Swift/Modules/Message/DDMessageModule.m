//
//  DDMessageModule.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-27.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDMessageModule.h"
#import "MTTDatabaseUtil.h"


#import "DDGroupModule.h"

#import "MTTDDNotification.h"

#import "TeamTalk_Swift-Swift.h"


@interface DDMessageModule(){

    NSMutableDictionary* _unreadMessages;
    
    NSMutableArray *_delegates;
    
    ReceiveMessageAPI *receiveMessageApi;
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
        _delegates = [[NSMutableArray alloc]init];
        
        receiveMessageApi = [[ReceiveMessageAPI alloc]init];

        [self p_registerReceiveMessageAPI];
    }
    return self;
}

-(void)addDelegate:(id<DDMessageModuleDelegate>)delegate{
    
    if (![_delegates containsObject:delegate]){
        [_delegates addObject:delegate];
    }
}

-(void)removeDelegate:(id<DDMessageModuleDelegate>)delegate
{
    while ([_delegates containsObject:delegate]) {
        [_delegates removeObject:delegate];
    }
}
-(void)removeAllDelegate{
    [_delegates removeAllObjects];
}



- (void)dealloc
{
    [_delegates removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

 


-(void)sendMsgRead:(MTTMessageEntity *)message
{
    SessionType_Objc type = SessionType_ObjcSessionTypeSingle;
    if (message.sessionType == SessionType_ObjcSessionTypeGroup){
        type = SessionType_ObjcSessionTypeGroup;
    }
    uint32_t sessionid = [MTTBaseEntity pbIDFromLocalID:message.sessionId];
    MsgReadACKAPI* readACK = [[MsgReadACKAPI alloc] initWithSessionID:sessionid  msgID:message.msgID sessionType:type];
    [readACK requestWithParameters:nil Completion:nil];
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

    [receiveMessageApi registerAPIInAPIScheduleReceiveData:^(MTTMessageEntity* object, NSError *error) {
        if (object){
            
            object.state = DDMessageStateSendSuccess;
            
            uint32_t sessionid = [MTTBaseEntity pbIDFromLocalID:object.sessionId];
            SessionType_Objc type = (SessionType_Objc)object.sessionType;
            ReceiveMessageACKAPI *rmack = [[ReceiveMessageACKAPI alloc] initWithMsgID:object.msgID sessionID:sessionid sessionType:type];
            [rmack requestWithParameters:nil Completion:^(id response, NSError *error) {
            }];
            
            
            if ([object isGroupMessage]) {
                MTTGroupEntity *group = [[DDGroupModule instance] getGroupByGId:object.sessionId];
                if (group.isShield == 1) {
                    [self sendMsgRead:object];
                }
            }
            
            for (id<DDMessageModuleDelegate> obj in _delegates) {
                if ([obj respondsToSelector:@selector(onReceiveMessage:)]){
                    [obj onReceiveMessage:object];
                }
            }
            
//            [[NSNotificationCenter defaultCenter]postNotificationName:DDNotificationReceiveMessage object:object];
        }
    }];
    
}

-(void)getMessageFromServer:(NSInteger)fromMsgID currentSession:(MTTSessionEntity *)session count:(NSInteger)count Block:(void(^)(NSMutableArray *array, NSError *error))block
{
    uint32_t sessionid = [MTTBaseEntity pbIDFromLocalID:session.sessionID];
    GetMessageQueueAPI *getMessageQueue = [[GetMessageQueueAPI alloc]initWithSessionID:sessionid sessionType:session.sessionType msgIDBegin:(int)fromMsgID count:count];
    
    [getMessageQueue requestWithParameters:nil Completion:^(NSMutableArray *response, NSError *error) {
        block(response,error);
    }];
    
}


@end

//
//  SessionModule.m
//  TeamTalk
//
//  Created by Michael Scofield on 2014-12-05.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "SessionModule.h"

#import "NSDictionary+Safe.h"
#import "MTTDatabaseUtil.h"

#import "SpellLibrary.h"
#import "DDGroupModule.h"
#import "MTTDDNotification.h"

#import "TeamTalk_Swift-Swift.h"


@interface SessionModule()
@property(strong)NSMutableDictionary *sessions;
@end

@implementation SessionModule

+ (instancetype)instance
{
    static SessionModule* module;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        module = [[SessionModule alloc] init];
        
    });
    return module;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sessions = [NSMutableDictionary new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sentMessageSuccessfull:) name:@"SentMessageSuccessfull" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMessageReadACK:) name:@"MessageReadACK" object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(n_receiveMessageNotification:)
                                                     name:DDNotificationReceiveMessage
                                                   object:nil];
        MsgReadNotifyAPI *msgReadNotify = [[MsgReadNotifyAPI alloc] init];
        [msgReadNotify registerAPIInAPIScheduleReceiveData:^(NSDictionary *object, NSError *error) {
            NSString *fromId= [object objectForKey:@"from_id"];
            NSInteger msgID = [[object objectForKey:@"msgId"] integerValue];
            SessionType_Objc type = [[object objectForKey:@"type"] intValue];
            [self cleanMessageFromNotifi:msgID SessionID:fromId Session:type];
        }];
    }
    return self;
}
-(MTTSessionEntity *)getSessionById:(NSString *)sessionID
{
    return [self.sessions safeObjectForKey:sessionID];
}
-(void)removeSessionById:(NSString *)sessionID
{
    [self.sessions removeObjectForKey:sessionID];
}
-(void)addToSessionModel:(MTTSessionEntity *)session
{
    [self.sessions safeSetObject:session forKey:session.sessionID];
}
-(NSUInteger)getAllUnreadMessageCount
{
    NSArray *allSession = [self getAllSessions];
    __block NSUInteger count = 0;
    [allSession enumerateObjectsUsingBlock:^(MTTSessionEntity *obj, NSUInteger idx, BOOL *stop) {
        NSInteger unReadMsgCount = obj.unReadMsgCount;
        if(obj.isGroupSession){
            MTTGroupEntity *group = [[DDGroupModule instance] getGroupByGId:obj.sessionID];
            if (group) {
                if(group.isShield){
                    if(obj.unReadMsgCount){
                        unReadMsgCount = 0;
                    }
                }
            }
        }
        count += unReadMsgCount;
    }];
    return count;
//    return [[[self getAllSessions] valueForKeyPath:@"@sum.unReadMsgCount"] integerValue];
}
-(void)addSessionsToSessionModel:(NSArray *)sessionArray
{
    [sessionArray enumerateObjectsUsingBlock:^(MTTSessionEntity *session, NSUInteger idx, BOOL *stop) {
        [self.sessions safeSetObject:session forKey:session.sessionID];
    }];
}
-(void)getHadUnreadMessageSession:(void(^)(NSUInteger count))block
{
    GetUnreadMessagesAPI *getUnreadMessage = [GetUnreadMessagesAPI new];
    [getUnreadMessage requestWithObject:TheRuntime.user.objID Completion:^(NSDictionary *dic, NSError *error) {
        NSInteger m_total_cnt =[dic[@"m_total_cnt"] integerValue];
        NSArray *localsessions = dic[@"sessions"];
        [localsessions enumerateObjectsUsingBlock:^(MTTSessionEntity *obj, NSUInteger idx, BOOL *stop){
            if ([self getSessionById:obj.sessionID]) {
                MTTSessionEntity *session = [self getSessionById:obj.sessionID];
                obj.lastMsg = session.lastMsg;
                session=obj;
                [self addToSessionModel:obj];
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(sessionUpdate:Action:)]) {
                [self.delegate sessionUpdate:obj Action:ADD];
            }
        }];
        
        //[self addSessionsToSessionModel:sessions];
        block(m_total_cnt);
        //通知外层sessionmodel发生更新
    }];
}

-(NSUInteger )getMaxTime
{
    NSArray *array =[self getAllSessions];
    NSUInteger maxTime = [[array valueForKeyPath:@"@max.timeInterval"] integerValue];
    if (maxTime) {
        return maxTime;
    }
    return 0;
}
-(void)getRecentSession:(void(^)(NSUInteger count))block
{
    GetRecentSessionAPI *getRecentSession = [[GetRecentSessionAPI alloc] init];
    NSInteger localMaxTime = [self getMaxTime];
    [getRecentSession requestWithObject:@[@(localMaxTime)] Completion:^(NSArray *response, NSError *error) {

        NSMutableArray *array = [NSMutableArray arrayWithArray:response];
        
        [self addSessionsToSessionModel:array];
        
        [self getHadUnreadMessageSession:^(NSUInteger count) {}];
        
        [[MTTDatabaseUtil instance] updateRecentSessions:response completion:^(NSError *error) {}];
        
        block(0);

    }];
}

-(NSArray *)getAllSessions
{
    NSArray *sessions = [self.sessions allValues];
    [sessions enumerateObjectsUsingBlock:^(MTTSessionEntity *obj, NSUInteger idx, BOOL *stop) {
        if([MTTUtil checkFixedTop:obj.sessionID]){
            obj.isFixedTop = YES;
        }
    }];
    return [self.sessions allValues];
}
-(void)removeSessionByServer:(MTTSessionEntity *)session
{
    [self.sessions removeObjectForKey:session.sessionID];
    [[MTTDatabaseUtil instance] removeSession:session.sessionID];
    RemoveSessionAPI *removeSession = [RemoveSessionAPI new];
    SessionType_Objc sessionType = session.sessionType;
    [removeSession requestWithObject:@[session.sessionID,@(sessionType)] Completion:^(id response, NSError *error) {
       
    }];
}

-(void)clearSession{
    [self.sessions removeAllObjects];
}

-(void)getMessageReadACK:(NSNotification *)notification
{
      MTTMessageEntity* message = [notification object];
    if ([[self.sessions allKeys] containsObject:message.sessionId]) {
        MTTSessionEntity *session = [self.sessions objectForKey:message.sessionId];
        session.unReadMsgCount=session.unReadMsgCount-1;
    }
}
- (void)n_receiveMessageNotification:(NSNotification*)notification
{
    MTTMessageEntity* message = [notification object];

    SessionType_Objc sessionType;
    MTTSessionEntity *session;
    if ([message isGroupMessage]) {
        sessionType = SessionType_ObjcSessionTypeGroup;
    } else{
        sessionType = SessionType_ObjcSessionTypeSingle;
    }
   
    if ([[self.sessions allKeys] containsObject:message.sessionId]) {
         session = [self.sessions objectForKey:message.sessionId];
        session.lastMsg=message.msgContent;
        session.lastMsgID = message.msgID;
        session.timeInterval = message.msgTime;
        
        //Fixme:here
//        if (![message.sessionId isEqualToString:[ChattingMainViewController shareInstance].module.SessionEntity.sessionID]) {
//            if (![message.senderId isEqualToString:TheRuntime.user.objID]) {
//                    session.unReadMsgCount=session.unReadMsgCount+1;
//            }
//        }
        
    }else{
        session = [[MTTSessionEntity alloc]initWithSessionID:message.sessionId sessionName:nil  type:sessionType];
        session.lastMsg=message.msgContent;
        session.lastMsgID = message.msgID;
        session.timeInterval = message.msgTime;
        
        //Fixme:here
//        if (![message.
//              sessionId isEqualToString:[ChattingMainViewController shareInstance].module.SessionEntity.sessionID]) {
//            if (![message.senderId isEqualToString:TheRuntime.user.objID]) {
//                session.unReadMsgCount=session.unReadMsgCount+1;
//            }
//            
//        }
        [self addSessionsToSessionModel:@[session]];
    }
    [self updateToDatabase:session];
   
    if (self.delegate && [self.delegate respondsToSelector:@selector(sessionUpdate:Action:)]) {
        [self.delegate sessionUpdate:session Action:ADD];
    }
    
}
-(void)updateToDatabase:(MTTSessionEntity *)session{
    [[MTTDatabaseUtil instance] updateRecentSession:session completion:^(NSError *error) {
        
    }];
}
-(void)sentMessageSuccessfull:(NSNotification*)notification
{
    MTTSessionEntity* session = [notification object];
    [self addSessionsToSessionModel:@[session]];
    if (self.delegate && [self.delegate respondsToSelector:@selector(sessionUpdate:Action:)]) {
        [self.delegate sessionUpdate:session Action:ADD];
    }
     [self updateToDatabase:session];
}
-(void)loadLocalSession:(void(^)(bool isok))block
{
    [[MTTDatabaseUtil instance] loadSessionsCompletion:^(NSArray *session, NSError *error) {
        
        [self addSessionsToSessionModel:session];
        
        block(YES);
        
    }];

}
-(void)cleanMessageFromNotifi:(NSUInteger)messageID  SessionID:(NSString *)sessionid Session:(SessionType_Objc)type
{
    if(![sessionid isEqualToString:TheRuntime.user.objID]){
        MTTSessionEntity *session = [self getSessionById:sessionid];
        if (session) {
            NSInteger readCount =messageID-session.lastMsgID;
            if (readCount == 0) {
                session.unReadMsgCount =0;
                if (self.delegate && [self.delegate respondsToSelector:@selector(sessionUpdate:Action:)]) {
                    [self.delegate sessionUpdate:session Action:ADD];
                }
                [self updateToDatabase:session];
                
            }else if(readCount > 0){
                session.unReadMsgCount =readCount;
                if (self.delegate && [self.delegate respondsToSelector:@selector(sessionUpdate:Action:)]) {
                    [self.delegate sessionUpdate:session Action:ADD];
                }
                [self updateToDatabase:session];
            }
            MsgReadACKAPI* readACK = [[MsgReadACKAPI alloc] init];
            [readACK requestWithObject:@[sessionid,@(messageID),@(type)] Completion:nil];
        }
        
    }
}

@end

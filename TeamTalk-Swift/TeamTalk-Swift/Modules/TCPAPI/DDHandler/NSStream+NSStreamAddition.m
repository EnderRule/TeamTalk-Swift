//
//  NSStream+NSStreamAddition.m
//  mtalk
//
//  Created by maye on 13-10-23.
//  Copyright (c) 2015年 MoguIM. All rights reserved.
//


#import "NSStream+NSStreamAddition.h"
//TODO we need to check this code later..by zouye
@implementation NSStream (NSStreamAddition)
+ (void)getStreamsToHostNamed:(NSString *)hostName port:(NSInteger)port inputStream:(NSInputStream **)inputStream outputStream:(NSOutputStream **)outputStream
{
    CFHostRef           host;
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
	
    readStream = NULL;
    writeStream = NULL;
    
    host = CFHostCreateWithName(NULL, (__bridge CFStringRef) hostName);
    if (host != NULL) {
        (void) CFStreamCreatePairWithSocketToCFHost(NULL, host, (SInt32)port, &readStream, &writeStream);
        CFRelease(host);
    }
    
    if (inputStream == NULL) {
        if (readStream != NULL) {
            CFRelease(readStream);
        }
    } else {
        *inputStream = (__bridge NSInputStream *) readStream;
    }
    if (outputStream == NULL) {
        if (writeStream != NULL) {
            CFRelease(writeStream);
        }
    } else {
        *outputStream =(__bridge NSOutputStream *) writeStream;
    }
}

@end

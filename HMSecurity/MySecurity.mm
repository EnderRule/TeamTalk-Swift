//
//  HMSecurity.m
//  HMSecurity
//
//  Created by HuangZhongQing on 2017/10/18.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonDigest.h>

#import "MySecurity.h"
#import "security.h"

#include <stdlib.h>


@implementation MySecurity

+(NSString *)encrypt:(NSString *)str{
    
    char *indata = (char *)[str cStringUsingEncoding:NSUTF8StringEncoding];
    int inlength = (int)str.length;
    char *outData;
    unsigned int *outLength;
    
    EncryptMsg(indata, inlength, &outData, &outLength);

    if (outData){
        return [NSString stringWithCString:outData encoding:NSUTF8StringEncoding];
    }
    
    return @"";
}

+(NSString *)decrypt:(NSString *)str{
    
    char *indata = (char *)[str cStringUsingEncoding:NSUTF8StringEncoding];
    int inlength = (int)str.length;
    char *outData;
    unsigned int *outLength;

    DecryptMsg(indata, inlength, &outData, &outLength);
    
    if (outData){
        return [NSString stringWithCString:outData encoding:NSUTF8StringEncoding];
    }
    return @"";
}

@end

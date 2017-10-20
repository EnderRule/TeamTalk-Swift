//
//  DataEncode.h
//  
//
//  Created by ankey on 15/4/30.
//
//

#import <Foundation/Foundation.h>


typedef enum :NSInteger {
    
    DEAlgrithmAES128 = 0,
    DEAlgrithmAES = 0,
    DEAlgrithmDES,
    DEAlgrithm3DES,
}DEAlgrithm;

typedef enum :NSInteger{
    DEActionEncrypt = 0,
    DEActionDecrypt
}DEAction;


extern const NSString *__nonnull DataEncodeDefaultKey;

@interface DataEncode : NSObject

+(NSString *__nonnull)DESDecrypt:(NSString * __nonnull)plainText key:(NSString *__nullable)key;
+(NSString *__nonnull)DESEncrypt:(NSString *__nonnull)plainText key:(NSString *__nullable)key;

+(NSString *__nonnull)TripleDESDecrypt:(NSString *__nonnull)plainText key:(NSString *__nullable)key;
+(NSString *__nonnull)TripleDESEncrypt:(NSString *__nonnull)plainText key:(NSString *__nullable)key;

+(NSString *__nonnull)AESDecrypt:(NSString *__nonnull)plainText key:(NSString *__nullable)key;
+(NSString *__nonnull)AESEncrypt:(NSString *__nonnull)plainText key:(NSString *__nullable)key;



+(NSData *__nonnull)DESDecryptData:(NSData * __nonnull)theData key:(NSString *__nullable)key;
+(NSData *__nonnull)DESEncryptData:(NSData * __nonnull)theData key:(NSString *__nullable)key;

+(NSData *__nonnull)TripleDESDecryptData:(NSData * __nonnull)theData key:(NSString *__nullable)key;
+(NSData *__nonnull)TripleDESEncryptData:(NSData * __nonnull)theData key:(NSString *__nullable)key;

+(NSData *__nonnull)AESDecryptData:(NSData * __nonnull)theData key:(NSString *__nullable)key;
+(NSData *__nonnull)AESEncryptData:(NSData * __nonnull)theData key:(NSString *__nullable)key;

/**
 handle function
 
 @param plainText text to encrypt or decrypt
 @param algorithm kCCAlgorithmDES、kCCAlgorithm3DES、kCCAlgorithmAES、kCCAlgorithmAES128
 @param action encrypt or decrypt
 @param key default is DataEncodeDefaultKey
 @return handled result
 */
+(NSString *__nonnull)handleText:(NSString *__nonnull)plainText algorithem:(DEAlgrithm)algorithm encryptOrDecrypt:(DEAction)action key:(NSString *__nullable)key;

+(NSData *__nonnull)handleData:(NSData *__nonnull)theData algorithem:(DEAlgrithm)algorithm encryptOrDecrypt:(DEAction)action key:(NSString *__nullable)key;

+(void)runExample;

+(NSData *__nonnull)hexStringToData:(NSString *__nonnull)hexStr;
+(NSString *__nonnull)dataToHexString:(NSData *__nonnull)data;

+ (NSString *__nonnull)getHexByDecimal:(NSInteger)decimal;
+ (NSInteger)getDecimalByBinary:(NSString *__nonnull)binary;
+ (NSInteger)getDecimalByHex:(NSString *__nonnull)hex;

@end

//
//  DataEncode.m
//  
//
//  Created by ankey on 15/4/30.
//
//

#import "DataEncode.h"
#import "GTMBase64.h"

const NSString *DataEncodeDefaultKey = @"Qo4lP7wUjxZpDl56invDaYqC2AXu3sSl";

@implementation DataEncode

//kCCAlgorithmAES128 = 0,
//kCCAlgorithmAES = 0,
//kCCAlgorithmDES,
//kCCAlgorithm3DES,
//kCCAlgorithmCAST,
//kCCAlgorithmRC4,
//kCCAlgorithmRC2,
//kCCAlgorithmBlowfish


//MARK:NSString
+(NSString *__nonnull)DESDecrypt:(NSString * __nonnull)plainText key:(NSString *__nullable)key
{
    return [self handleText:plainText algorithem:kCCAlgorithmDES encryptOrDecrypt:kCCDecrypt key:key];
}

+(NSString *__nonnull)DESEncrypt:(NSString *__nonnull)plainText key:(NSString *__nullable)key
{
    return [self handleText:plainText algorithem:kCCAlgorithmDES encryptOrDecrypt:kCCEncrypt key:key];
}

+(NSString *__nonnull)TripleDESDecrypt:(NSString *__nonnull)plainText key:(NSString *__nullable)key
{
    return [self handleText:plainText algorithem:kCCAlgorithm3DES encryptOrDecrypt:kCCDecrypt key:key];
}

+(NSString *__nonnull)TripleDESEncrypt:(NSString *__nonnull)plainText key:(NSString *__nullable)key
{
    return [self handleText:plainText algorithem:kCCAlgorithm3DES encryptOrDecrypt:kCCEncrypt key:key];
}

+(NSString *__nonnull)AESDecrypt:(NSString *__nonnull)plainText key:(NSString *__nullable)key
{
    return [self handleText:plainText algorithem:kCCAlgorithmAES128 encryptOrDecrypt:kCCDecrypt key:key];
}
+(NSString *__nonnull)AESEncrypt:(NSString *__nonnull)plainText key:(NSString *__nullable)key
{
    return [self handleText:plainText algorithem:kCCAlgorithmAES128 encryptOrDecrypt:kCCEncrypt key:key];
}

//MARK:NSData
+(NSData *__nonnull)DESDecryptData:(NSData * __nonnull)theData key:(NSString *__nullable)key
{
    return [self handleData:theData algorithem:kCCAlgorithmDES encryptOrDecrypt:kCCDecrypt key:key];
}

+(NSData *__nonnull)DESEncryptData:(NSData * __nonnull)theData key:(NSString *__nullable)key
{
    return [self handleData:theData algorithem:kCCAlgorithmDES encryptOrDecrypt:kCCEncrypt key:key];
}

+(NSData *__nonnull)TripleDESDecryptData:(NSData * __nonnull)theData key:(NSString *__nullable)key
{
    return [self handleData:theData algorithem:kCCAlgorithm3DES encryptOrDecrypt:kCCDecrypt key:key];
}

+(NSData *__nonnull)TripleDESEncryptData:(NSData * __nonnull)theData key:(NSString *__nullable)key
{
    return [self handleData:theData algorithem:kCCAlgorithm3DES encryptOrDecrypt:kCCEncrypt key:key];
}

+(NSData *__nonnull)AESDecryptData:(NSData * __nonnull)theData key:(NSString *__nullable)key
{
    return [self handleData:theData algorithem:kCCAlgorithmAES128 encryptOrDecrypt:kCCDecrypt key:key];
}
+(NSData *__nonnull)AESEncryptData:(NSData * __nonnull)theData key:(NSString *__nullable)key
{
    return [self handleData:theData algorithem:kCCAlgorithmAES128 encryptOrDecrypt:kCCEncrypt key:key];
}



+(NSString *__nonnull)handleText:(NSString *__nonnull)plainText algorithem:(CCAlgorithm)algorithm encryptOrDecrypt:(CCOperation)action key:(NSString *__nullable)key
{
    if (plainText.length <= 0){
        return @"";
    }
    if (algorithm != kCCAlgorithmDES && algorithm != kCCAlgorithm3DES && algorithm != kCCAlgorithmAES && algorithm != kCCAlgorithmAES128){
        NSLog( @"DataEncode surported algorithems are:kCCAlgorithmDES、kCCAlgorithm3DES、kCCAlgorithmAES、kCCAlgorithmAES128");
        return @"";
    }
    
    NSData *handleData;
    
    if (action == kCCDecrypt){
        handleData = [GTMBase64 decodeData:[plainText dataUsingEncoding:NSUTF8StringEncoding]];
    }else{
        handleData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSData *returnData = [self handleData:handleData algorithem:algorithm encryptOrDecrypt:action key:key];
    
    
    NSString *result;
    if (action == kCCDecrypt) {
        result = [[NSString alloc] initWithData: returnData encoding:NSUTF8StringEncoding];

    }else {
        result =   [GTMBase64 stringByEncodingData:returnData];
    }
    if (!result){
        return @"";
    }
    return result;
}




+(NSData *__nonnull)handleData:(NSData *__nonnull)theData algorithem:(CCAlgorithm)algorithm encryptOrDecrypt:(CCOperation)action key:(NSString *__nullable)key
{
    if (theData.length <= 0){
        return [[NSData alloc]init];
    }
    if (algorithm != kCCAlgorithmDES && algorithm != kCCAlgorithm3DES && algorithm != kCCAlgorithmAES && algorithm != kCCAlgorithmAES128){
        NSLog( @"DataEncode surported algorithems are:kCCAlgorithmDES、kCCAlgorithm3DES、kCCAlgorithmAES、kCCAlgorithmAES128");
        return [[NSData alloc]init];
    }
    NSString *theKey = key.length > 0 ? key:DataEncodeDefaultKey;
    
    const void *vplainText;
    size_t plainTextBufferSize;
    
    plainTextBufferSize = [theData length];
    vplainText = [theData bytes];
    
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    int keySize = 0;
    int blockSize = 0;
    int ccoptions =  kCCOptionECBMode | kCCOptionPKCS7Padding;
    
    if (algorithm == kCCAlgorithmAES || algorithm == kCCAlgorithmAES128){
        blockSize = kCCBlockSizeAES128;
        keySize = kCCKeySizeAES256;
        ccoptions = kCCOptionECBMode;   //aes 不用加padding
    }else if(algorithm == kCCAlgorithmDES){
        keySize = kCCKeySizeDES;
        blockSize = kCCBlockSizeDES;
    }else { // (algorithm == kCCAlgorithm3DES){
        keySize = kCCKeySize3DES;
        blockSize = kCCBlockSize3DES;
    }
    
    bufferPtrSize = (plainTextBufferSize + blockSize) & ~(blockSize - 1);
    
    
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    const void *vkey = (const void *)[theKey UTF8String];
    
    CCCrypt(action,
            algorithm,
            ccoptions,
            vkey,
            keySize,
            nil,
            vplainText,
            plainTextBufferSize,
            (void *)bufferPtr,
            bufferPtrSize,
            &movedBytes);
    
    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    free(bufferPtr);
    
    return myData;
}

+(void)runExample{
    NSString *raw = @"jlfsksjkh哈哈哈😆电风扇数据付了款4234230";
    
    NSString *en = [self TripleDESEncrypt:raw  key:nil];
    NSString *de = [self TripleDESDecrypt:en  key:nil];
    
    NSLog(@"DataEncode run Example:\n%@\n%@\n%@",raw,en,de );
    
//    DataEncode run Example:
//    jlfsksjkh哈哈哈😆电风扇数据付了款4234230
//    FQP+3p8H+yg+3f4hsH7FO5rwnqFPKhYmbquli1ewS4NrvAcdCfVd5jpTXk99elmA2qTpcgtxHLg=
//    jlfsksjkh哈哈哈😆电风扇数据付了款4234230
}

+(NSData *__nonnull)hexStringToData:(NSString *__nonnull)hexStr
{
    //    NSString *hexStr = @"ef5ff508a429f1978b4e0a765bd6b639c4b56561220df214";
    int len = (int)[hexStr length] / 2 ;
    char *bu = (char *)malloc(len);
    bzero(bu, len );
    for (int i = 0; i < [hexStr length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexStr substringWithRange:NSMakeRange(i, 2)];
        NSScanner * sc = [[NSScanner alloc] initWithString:hexCharStr] ;
        [sc scanHexInt:&anInt];
        bu[i / 2] = (char)anInt;
    }
    NSData *data = [[NSData alloc] initWithBytes:bu length:len];
    free(bu);
    
    return data;
}

+(NSString *__nonnull)dataToHexString:(NSData *__nonnull)data{
    NSString *str = [NSString stringWithFormat:@"%@",data];
    str = [str stringByReplacingOccurrencesOfString:@"<" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@">" withString:@""];
    return str;
}

+ (NSString *__nonnull)getHexByDecimal:(NSInteger)decimal {
    
    NSString *hex =@"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i<9; i++) {
        
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
                
            case 10:
                letter =@"a"; break;
            case 11:
                letter =@"b"; break;
            case 12:
                letter =@"c"; break;
            case 13:
                letter =@"d"; break;
            case 14:
                letter =@"e"; break;
            case 15:
                letter =@"f"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {
            
            break;
        }
    }
    return hex;
}

+ (NSString *__nonnull)getBinaryByHex:(NSString *__nonnull)hex {
    
    NSMutableDictionary *hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [hexDic setObject:@"0000" forKey:@"0"];
    [hexDic setObject:@"0001" forKey:@"1"];
    [hexDic setObject:@"0010" forKey:@"2"];
    [hexDic setObject:@"0011" forKey:@"3"];
    [hexDic setObject:@"0100" forKey:@"4"];
    [hexDic setObject:@"0101" forKey:@"5"];
    [hexDic setObject:@"0110" forKey:@"6"];
    [hexDic setObject:@"0111" forKey:@"7"];
    [hexDic setObject:@"1000" forKey:@"8"];
    [hexDic setObject:@"1001" forKey:@"9"];
    [hexDic setObject:@"1010" forKey:@"A"];
    [hexDic setObject:@"1011" forKey:@"B"];
    [hexDic setObject:@"1100" forKey:@"C"];
    [hexDic setObject:@"1101" forKey:@"D"];
    [hexDic setObject:@"1110" forKey:@"E"];
    [hexDic setObject:@"1111" forKey:@"F"];
    
    NSString *binary = @"";
    for (int i=0; i<[hex length]; i++) {
        
        NSString *key = [hex substringWithRange:NSMakeRange(i, 1)];
        NSString *value = [hexDic objectForKey:key.uppercaseString];
        if (value) {
            
            binary = [binary stringByAppendingString:value];
        }
    }
    return binary;
}
+ (NSInteger)getDecimalByBinary:(NSString *__nonnull)binary {
    
    NSInteger decimal = 0;
    for (int i=0; i<binary.length; i++) {
        
        NSString *number = [binary substringWithRange:NSMakeRange(binary.length - i - 1, 1)];
        if ([number isEqualToString:@"1"]) {
            
            decimal += pow(2, i);
        }
    }
    return decimal;
}

+(NSInteger)getDecimalByHex:(NSString *)hex{
    NSString *binary = [self getBinaryByHex:hex];
    NSInteger decimal = [self getDecimalByBinary:binary];
    return decimal;
}

@end

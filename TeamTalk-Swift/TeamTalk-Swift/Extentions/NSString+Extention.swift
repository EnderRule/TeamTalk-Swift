//
//  NSString+Extention.swift
//  heyfriendS
//
//  Created by HZQ on 2016/11/9.
//  Copyright © 2016年 online. All rights reserved.
//

import UIKit
import Foundation

extension String {
    
    var md5 : String{

        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen);
        CC_MD5(self.cString(using: String.Encoding.utf8)!, CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8)), result);
        
        var hash2:String = ""
        for i in 0 ..< digestLen {
            hash2 = hash2.appendingFormat("%02x", result[i])
        }
        free(result) //释放內存
        return hash2
    }
    
    var length:Int{
        return (self as NSString).length
        //return self.lengthOfBytes(using: .utf8)
    }
    var byteLength:Int{
        return  self.lengthOfBytes(using: .utf8)
    }
    
    func parseUrlParas(host:String)->[String:Any]{
        var paras:[String:Any] = [:]
        if self.length <= 0{
            
        }else if !self.contains(host){
            
        }else{
            var tempStr:NSString = self as NSString
            if tempStr.contains("?"){
                tempStr = tempStr.substring(from: tempStr.range(of: "?").location + 1) as NSString
            }
            
            let key_valueStrs:[String] = tempStr.components(separatedBy: "&")
            
            for key_valueStr in key_valueStrs {
                let key_valuearray = key_valueStr.components(separatedBy: "=")
                if key_valuearray.count > 1{
                    paras.updateValue(key_valuearray[1], forKey: key_valuearray[0])
                }
            }
            
            tempStr = self as NSString
            tempStr = tempStr.substring(from: tempStr.range(of: "://").location + 3) as NSString
            if tempStr.contains("?"){
                tempStr = tempStr.substring(to: tempStr.range(of: "?").location) as NSString
            }
            let subPaths = tempStr.components(separatedBy: "/")
            paras.updateValue(subPaths, forKey: "subPaths")
        }
        
//        debugPrint("parse url \(self)  result:\(paras)")
        return paras

    }
    
    func htmlToAttributeString()->NSAttributedString?{
        do{
            let htmlDocString = "<!DOCTYPE html> <html lang=\"zh-TW\"> <head> <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"> </head> <body > \(self) </body> </html>"
            let attString = try NSAttributedString.init(data: htmlDocString.data(using: .utf8)!, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil)
            return attString
        }catch{
            debugPrint("init attString error:\(error.localizedDescription)")
            return nil
        }
    }
    
    func htmlToAttributeString(add attributes:[String:Any])->NSAttributedString?{
        let attString = self.htmlToAttributeString()
        if attString != nil{
            let mutableAttString:NSMutableAttributedString = NSMutableAttributedString.init(attributedString: attString!)
            mutableAttString.addAttributes(attributes, range: NSMakeRange(0, attString!.length))
            return mutableAttString
        }else{
            return nil
        }
    }
    
//    let _ = String().components(separatedBy: CharacterSet.init(charactersIn: ",."))

}

//- (NSString *)hexadecimalString {
//    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
//    
//    if (!dataBuffer)
//    return [NSString string];
//    
//    NSUInteger          dataLength  = [self length];
//    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
//    
//    for (int i = 0; i < dataLength; ++i)
//    [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
//    
//    return [NSString stringWithString:hexString];
//}

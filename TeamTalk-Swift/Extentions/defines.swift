//
//  File.swift
//  heyfriendS
//
//  Created by HZQ on 2016/10/28.
//  Copyright © 2016年 online. All rights reserved.
//

import Foundation
import UIKit
import AdSupport

//MARK:debug設置

#if DEBUG
let DEBUGMode = true
#else
let DEBUGMode = false
#endif

let APP_URL             = "https://itunes.apple.com/lookup?id=%@"

//MARK:App基本信息常量
let APPMainInfo         = JSON.init(Bundle.main.infoDictionary ?? ["AppID":"1206669706"])
let AppID               = APPMainInfo["AppID"].stringValue
let FB_APP_ID           = APPMainInfo["FacebookAppID"].stringValue
let FBDisplayName       = APPMainInfo["FacebookDisplayName"].stringValue
let APP_VERSION         = APPMainInfo["CFBundleShortVersionString"].stringValue
let APP_BUILD_VERSION   = APPMainInfo["CFBundleVersion"].stringValue
let APP_Name            = APPMainInfo["CFBundleDisplayName"].stringValue


//MARK:其他輔助常量、function
func SCREEN_WIDTH()->CGFloat{return UIScreen.main.bounds.size.width }
func SCREEN_HEIGHT()->CGFloat{return UIScreen.main.bounds.size.height}

let SYS_VERSION         = ((UIDevice.current.systemVersion as NSString).floatValue)
func isiOS(version:Float)->Bool{
    return (SYS_VERSION >= version)
}

let IS_iPad             = UIDevice.current.model.lowercased().contains("ipad")

func TIMESTAMP()->String{
    return NSString.localizedStringWithFormat("%ld", Int(NSDate().timeIntervalSince1970)).replacingOccurrences(of: ",", with: "") as String
}

func IDFA()->String{
    return ASIdentifierManager.shared().advertisingIdentifier.uuidString;
}
func PushToken()->Data {
    return (UserDefaults.standard.value(forKey: "NewestPushToken") as? Data) ?? Data.init()
}
func setPushToken(data:Data){
    UserDefaults.standard.setValue(data, forKey: "NewestPushToken")
    UserDefaults.standard.synchronize()
}
func PushID()->String{
    var pushToken:NSString =  NSString.init(format: "%@", PushToken() as CVarArg)
    
    pushToken = pushToken.replacingOccurrences(of: "<", with: "") as NSString
    pushToken = pushToken.replacingOccurrences(of: ">", with: "") as NSString
    pushToken = pushToken.replacingOccurrences(of: " ", with: "") as NSString
    
    if pushToken.length >= 32 {
        return pushToken as String
    }else{
        return ""
    }
}

func dispatch(after:Double,task:@escaping (()->Void)){
    
    DispatchQueue.main.asyncAfter(deadline: .now() + after, execute:task)
}

func dispatch_globle(after:Double,task:@escaping (()->Void)){
    DispatchQueue.global().asyncAfter(deadline: .now() + after, execute:task)
}

func dispatch_queue(label:String,after:Double,task:@escaping (()->Void)){
    DispatchQueue.init(label: label, qos: .default, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil).async(execute: task)
}



//MARK:字符串常量
let defaultLoadingTip   = "請稍等..."
let defaultLoadFailTip   = "載入失敗"




let mainTipTitleFont:UIFont = UIFont.systemFont(ofSize: 15);

func defaultShadow()->NSShadow{
    let shadow = NSShadow.init()
    shadow.shadowBlurRadius = 3.0
    shadow.shadowColor = UIColor.gray
    shadow.shadowOffset = CGSize.init(width: 1.5, height: 3)
    return shadow
}

let defaultPaddingWidth:CGFloat = 10.0


import ObjectiveC
 func swizzling_exchangeMethod(clazz:AnyClass ,originalSelector: Selector,swizzledSelector: Selector){
    let originalMethod = class_getInstanceMethod(clazz, originalSelector);
    let swizzledMethod = class_getInstanceMethod(clazz, swizzledSelector);
    let success = class_addMethod(clazz, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
    if (success) {
        class_replaceMethod(clazz, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

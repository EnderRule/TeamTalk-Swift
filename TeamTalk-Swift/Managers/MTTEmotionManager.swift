//
//  MTTEmotionManager.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/25.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class MTTEmotionManager: NSObject {
    
    static let shared:MTTEmotionManager = MTTEmotionManager()
    
    static var mgjEmotionDic:[String:String] = ["[牙牙撒花]":"221",
                                                "[牙牙尴尬]":"222",
                                                "[牙牙大笑]":"223",
                                                "[牙牙组团]":"224",
                                                "[牙牙凄凉]":"225",
                                                "[牙牙吐血]":"226",
                                                "[牙牙花痴]":"227",
                                                "[牙牙疑问]":"228",
                                                "[牙牙爱心]":"229",
                                                "[牙牙害羞]":"230",
                                                "[牙牙牙买碟]":"231",
                                                "[牙牙亲一下]":"232",
                                                "[牙牙大哭]":"233",
                                                "[牙牙愤怒]":"234",
                                                "[牙牙挖鼻屎]":"235",
                                                "[牙牙嘻嘻]":"236",
                                                "[牙牙漂漂]":"237",
                                                "[牙牙冰冻]":"238",
                                                "[牙牙傲娇]":"239",
                                                "[牙牙闪电]":"240"]
    
    var nimDefaultEmojiDic:[[String:Any]] = []
    
    var chartLetDic:[String:[String]] = [:]
    
    override init() {
        super.init()
        
        self.loadEmotionDics()
    }
    
    func loadEmotionDics(){
        guard let nimkitemotionBundle = Bundle.main.path(forResource: "NIMKitEmotion", ofType: "bundle") else{return }
        
        let defaultEmojiDir = (nimkitemotionBundle as NSString).appendingPathComponent("Emoji")
        var isEmojiDir:ObjCBool = ObjCBool.init(false)
         FileManager.default.fileExists(atPath: defaultEmojiDir, isDirectory: &isEmojiDir)
        if isEmojiDir.boolValue{
            let plistfilepath = (defaultEmojiDir as NSString).appendingPathComponent("emoji.plist")
            if FileManager.default.fileExists(atPath: plistfilepath){
                
                let array = NSArray.init(contentsOfFile: plistfilepath) ?? []
                if array.count > 0 {
                    let json = JSON.init(array.firstObject as? [String:Any] ?? [:])
                    
                    nimDefaultEmojiDic = json["data"].arrayObject as? [[String:Any]] ?? []
                }
            }
        }
        
        let charletDir = (nimkitemotionBundle as NSString).appendingPathComponent("Chartlet")
        var isCharletDir:ObjCBool = ObjCBool.init(false)
        FileManager.default.fileExists(atPath: charletDir, isDirectory: &isCharletDir)
        if isCharletDir.boolValue{
            
            
        }
    }
    
    func isEmotion(msgContent:String )->Bool{
        guard msgContent.hasPrefix("[") && msgContent.hasSuffix("]") else {
            return false
        }
        
        if  (MTTEmotionManager.mgjEmotionDic[msgContent] ?? "").length > 0{
            return true
        }
        
//        for obj in nimDefaultEmojiDic {
//            if obj["tag"] as? String ?? "" == msgContent {
//                return true
//            }
//        }
        return false
        
    }
}

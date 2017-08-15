//
//  MTTBaseEntity.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class MTTBaseEntity: NSObject {
    var lastUpdateTime:Int32 = 0
    var objID:String = ""
    var objectVersion:Int = 0
    
    func getOriginalID()->Int{
        let parts = self.objID.components(separatedBy: "_")
        
        if parts.count >= 2 {
            return (parts[1] as NSString).integerValue
        }else{
            return 0
        }
    }
}

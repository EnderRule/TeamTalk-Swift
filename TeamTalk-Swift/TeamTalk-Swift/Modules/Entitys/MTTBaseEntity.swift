//
//  MTTBaseEntity.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

/*
 *基础类，不可直接使用
 */
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

extension MTTBaseEntity {
    class func pbIDFrom(localID:String)->UInt32{
        return UInt32((localID as NSString).integerValue)
    }
    class func localIDFrom(pbID:UInt32)->String {
        return "\(pbID)"
    }
}

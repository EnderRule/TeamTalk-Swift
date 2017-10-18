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
public class MTTBaseEntity:NSObject {
    
}

public extension MTTBaseEntity {
    public class func pbIDFrom(localID:String)->UInt32{
        let components = localID.components(separatedBy: "_")
        if components.count >= 2{
             return UInt32((components[1] as NSString).intValue)
        }
        return UInt32((localID as NSString).intValue)
    }
    public class func localIDFrom(pbID:UInt32)->String {
        return "\(pbID)"
    }
}

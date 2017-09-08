//
//  HMChattingModule.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/9/8.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

let HM_Message_Page_Item_Count:Int = 20

typealias HMLoadMoreMessageCompletion = ((Int,NSError?)->Void)

class HMChattingModule: NSObject {

    var sessionEntity:MTTSessionEntity = MTTSessionEntity.init()
    
    var msgIDs:[UInt32] = []
    
    var showingMessages:[Any] = []
    
    
    
}




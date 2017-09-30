//
//  MTTDepartmentEntity.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class MTTDepartmentEntity: NSObject {

    var departID:String = ""
    var parentID:String = ""
    var title :String = ""
    var myDescription:String = ""
    var leader:String = ""
    var status:Int = 0
    var departCount:Int = 0
    
    public convenience init(infoDic:[String:Any]){
        self.init()
        self.updateValues(info: infoDic)
        self.myDescription = infoDic["description"] as? String ?? ""
    }
}

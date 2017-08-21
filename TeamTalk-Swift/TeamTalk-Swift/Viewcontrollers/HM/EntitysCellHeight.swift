//
//  EntitysCellHeight.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit


extension MTTMessageEntity{
    func cellHeight()->CGFloat {
        
        
        
        
        
        return 120;
    }
}

extension MTTUserEntity {
    func cellHeight()->CGFloat {
        return 64
    }
}

extension MTTPromtEntity {
    func cellHeight()->CGFloat{
        return 30
    }
}

extension MTTSessionEntity {
    func cellHeight()->CGFloat{
        return 64
    }
}

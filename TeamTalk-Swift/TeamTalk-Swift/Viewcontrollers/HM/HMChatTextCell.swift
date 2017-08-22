//
//  HMChatTextCell.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class HMChatTextCell: HMBaseCell {

    var textView:UITextView = UITextView.init()
    
    override func setupCustom() {
        
        textView.isEditable = false
        textView.isSelectable = false
        textView.font = UIFon
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

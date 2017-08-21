//
//  HMChatPromptCell.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class HMChatPromptCell: HMBaseCell {

    var promptLabel:UILabel = UILabel.init()
    
    override func setupCustom() {
        promptLabel.backgroundColor = UIColor.gray
        promptLabel.add(corners: .allCorners, radius: .init(width: 10, height: 10))
        promptLabel.font = UIFont.systemFont(ofSize: 11)
        promptLabel.textAlignment = .center
        
        self.contentView.addSubview(promptLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var newsize = promptLabel.sizeThatFits(CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: 20))
        newsize.width += 10
        promptLabel.frame.size = newsize
        promptLabel.center = self.contentView.center
    }
    
    override func configWith(object: Any) {
        if let  prompt = object as? MTTPromtEntity {
            promptLabel.text = prompt.message
        }
    }

}

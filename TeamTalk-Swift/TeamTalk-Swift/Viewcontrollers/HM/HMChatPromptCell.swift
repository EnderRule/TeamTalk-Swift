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
        self.contentView.backgroundColor = UIColor.clear
        
        promptLabel.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        promptLabel.layer.cornerRadius = 8
        promptLabel.clipsToBounds = true
        promptLabel.font = UIFont.systemFont(ofSize: 11)
        promptLabel.textAlignment = .center
        promptLabel.textColor = colorTitle
        self.contentView.addSubview(promptLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var newsize = promptLabel.sizeThatFits(CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: 20))
        newsize.width += 10
        promptLabel.frame = .init(x: 0, y: 0, width: newsize.width, height: 20)
        promptLabel.center = self.contentView.center
        print(promptLabel.frame,promptLabel.text ?? "nil text")
    }
    
    override func configWith(object: Any) {
        if let  prompt = object as? DDPromptEntity {
            print(self.classForCoder,"config with \(prompt.message)")
            
            promptLabel.text = prompt.message
        }
    }

}

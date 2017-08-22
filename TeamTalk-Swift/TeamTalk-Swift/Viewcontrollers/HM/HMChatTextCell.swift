//
//  HMChatTextCell.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit



class HMChatTextCell: HMChatBaseCell {

    var textView:UITextView = UITextView.init()
    
    override func setupCustom() {
        super.setupCustom()
        
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isSelectable = false
        textView.font = fontNormal
        
        self.contentView.addSubview(textView)
    }
    

    override func setContent(message: MTTMessageEntity) {
        super.setContent(message: message)
        
        self.textView.text = message.msgContent
    }
    
    override func layoutContentView(message: MTTMessageEntity) {
        let sizecontent = self.contentSizeFor(message: message)
        
         self.textView.mas_makeConstraints { (maker ) in
            maker?.left.mas_equalTo()(self.bubbleImgv.mas_left)?.offset()(self.bubbleLeftEdge())
            maker?.top.mas_equalTo()(self.bubbleImgv.mas_top)?.offset()(self.bubbleTopEdge())
            maker?.size.mas_equalTo()(sizecontent)
        }
    }
    
    override func contentSizeFor(message: MTTMessageEntity) -> CGSize {
        
        let tempText:String = textView.text ?? ""
        
        textView.text = message.msgContent
        
        var size = textView.sizeThatFits(.init(width: maxChatTextWidth, height: 1000))
        if size.width > maxChatTextWidth {
            size.width = maxChatTextWidth
        }
        textView.text = tempText
        return size
    }
    
    
    
}

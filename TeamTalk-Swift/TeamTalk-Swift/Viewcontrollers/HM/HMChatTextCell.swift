//
//  HMChatTextCell.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit



class HMChatTextCell: HMChatBaseCell,M80AttributedLabelDelegate {

    var attTextLabel:M80AttributedLabel = M80AttributedLabel.init()
    
    override func setupCustom() {
        super.setupCustom()
        
        attTextLabel.delegate = self
        attTextLabel.numberOfLines = 0
        attTextLabel.lineBreakMode = .byWordWrapping
        attTextLabel.backgroundColor = UIColor.clear
        attTextLabel.font = fontTitle
        
        
        self.contentView.addSubview(attTextLabel)
    }

    override func setContent(message: MTTMessageEntity) {
        super.setContent(message: message)
        
        attTextLabel.nim_setText(message.msgContent)

        self.attTextLabel.mas_remakeConstraints { (maker ) in
            maker?.left.mas_equalTo()(self.bubbleImgv.mas_left)?.offset()(self.bubbleLeftEdge())
            maker?.top.mas_equalTo()(self.bubbleImgv.mas_top)?.offset()(self.bubbleTopEdge())
            
            maker?.size.mas_equalTo()(self.contentSizeFor(message: message))
            //            maker?.bottom.mas_equalTo()(self.bubbleImgv.mas_bottom)?.offset()(-self.bubbleBottomEdge())
            //            maker?.right.mas_equalTo()(self.bubbleImgv.mas_right)?.offset()(-self.bubbleRightEdge())
        }
    }
    
    override func layoutContentView(message: MTTMessageEntity) {
    }
    
    override func contentSizeFor(message: MTTMessageEntity) -> CGSize {
        
        
        attTextLabel.nim_setText(message.msgContent)
        
        var size = attTextLabel.sizeThatFits(.init(width: maxChatContentWidth, height: 1000))
        if size.width > maxChatContentWidth {
            size.width = maxChatContentWidth
        }
        //为了协调，最小宽度20、高度20
        if size.height < 20{
            size.height = 20
        }
        if size.width < 20 {
            size.width = 20
        }
        return size
    }
    
    func m80AttributedLabel(_ label: M80AttributedLabel, clickedOnLink linkData: Any) {
        
    }
    
}

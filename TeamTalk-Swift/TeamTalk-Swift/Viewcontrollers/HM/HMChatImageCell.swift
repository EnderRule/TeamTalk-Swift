//
//  HMChatImageCell.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class HMChatImageCell: HMChatBaseCell {

    var mainImgv:UIImageView = UIImageView.init()
    
    override func setupCustom() {
        super.setupCustom()
        
        mainImgv.contentMode = .scaleAspectFit
        
        self.contentView.addSubview(mainImgv)
    }
    
    
    override func setContent(message: MTTMessageEntity) {
        super.setContent(message: message)
        
        var imageURL:String = message.msgContent
        imageURL = imageURL.replacingOccurrences(of: DD_MESSAGE_IMAGE_PREFIX, with: "")
        imageURL = imageURL.replacingOccurrences(of: DD_MESSAGE_IMAGE_SUFFIX, with: "")
        
        self.mainImgv.setImage(str: imageURL)
    }
    
    override func layoutContentView(message: MTTMessageEntity) {
        let sizecontent = self.contentSizeFor(message: message)
        
        self.mainImgv.mas_makeConstraints { (maker ) in
            maker?.left.mas_equalTo()(self.bubbleImgv.mas_left)?.offset()(self.bubbleLeftEdge())
            maker?.top.mas_equalTo()(self.bubbleImgv.mas_top)?.offset()(self.bubbleTopEdge())
            maker?.size.mas_equalTo()(sizecontent)
        }
    }
    
    override func contentSizeFor(message: MTTMessageEntity) -> CGSize {
        return CGSize.init(width: 150, height: 150 * 1.618)
    }

}

//
//  HMChatEmotionCell.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class HMChatEmotionCell: HMChatImageCell {
    
    override func setContent(message: MTTMessageEntity) {
        super.setContent(message: message)
        
        self.handleEmotion(message: message) { (catagoryID,emojiID ) in
            
            let image = UIImage.nim_loadChartlet(catagoryID, name: emojiID)
            self.mainImgv.image = image
            
//            HMPrint("set emotion :",message.msgContent ,catagoryID,emojiID,image ?? "nil emoji image")
        }
    }
    
    override func layoutContentView(message: MTTMessageEntity) {
        self.mainImgv.mas_makeConstraints { (maker ) in
            maker?.left.mas_equalTo()(self.bubbleImgv.mas_left)?.offset()(self.bubbleLeftEdge())
            maker?.top.mas_equalTo()(self.bubbleImgv.mas_top)?.offset()(self.bubbleTopEdge())
            maker?.bottom.mas_equalTo()(self.bubbleImgv.mas_bottom)?.offset()(-self.bubbleBottomEdge())
            maker?.right.mas_equalTo()(self.bubbleImgv.mas_right)?.offset()(-self.bubbleRightEdge())

        }
        self.bubbleImgv.isHidden = true  //显示贴图表情时、隐藏气泡
    }
    
    override func contentSizeFor(message: MTTMessageEntity) -> CGSize {
        return CGSize.init(width: 120, height: 120)
    }
    
    private func handleEmotion(message:MTTMessageEntity,compeletion:((String,String)->Void)){  //返回 表情分类ID 和 表情文件名
        
        var categoryID:String = message.emojiCategory
        var EmojiID:String = message.emojiName
        EmojiID = (EmojiID as NSString).deletingPathExtension

        let EmojiText:String = message.emojiText
        if EmojiText.hasPrefix("[牙牙") && EmojiText.hasSuffix("]"){
            categoryID = "mgj"
            
            EmojiID = MTTEmotionManager.mgjEmotionDic[EmojiText] ?? "" 
        }
        compeletion(categoryID,EmojiID)
     }
}

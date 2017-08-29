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
        
        self.handleEmotion(message: message) { (catagoryID,emojiName ) in
            
            let image = UIImage.nim_loadChartlet(catagoryID, name: emojiName)
            self.mainImgv.image = image
            
//            debugPrint("set emotion :",message.msgContent ,catagoryID,emojiName,image ?? "nil emoji image")
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
        return CGSize.init(width: 150, height: 150)
    }
    
    private func handleEmotion(message:MTTMessageEntity,compeletion:((String,String)->Void)){  //返回 表情分类ID 和 表情文件名
        var catagoryID:String = ""
        var EmojiName:String = ""
        
        var msgContent = String.init(stringLiteral: message.msgContent)
        if msgContent.hasPrefix("[") && msgContent.hasSuffix("]"){
            
            if msgContent.hasPrefix("[牙牙"){ //蘑菇街的表情
                catagoryID = "mgj"
                EmojiName = MTTMessageEntity.mgjEmotionDic[msgContent] ?? ""
            }else{
            
                msgContent = msgContent.replacingOccurrences(of: "[", with: "")
                msgContent = msgContent.replacingOccurrences(of: "]", with: "")
                
                let components = msgContent.components(separatedBy: "/")
                if components.count >= 2{
                    catagoryID = components[0]
                    EmojiName = components[1]
                }else {
                    catagoryID = msgContent
                    EmojiName = msgContent
                }
            }
        }
        
        compeletion(catagoryID,EmojiName)
    }

}

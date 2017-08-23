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
        mainImgv.backgroundColor = UIColor.clear
        
        self.contentView.addSubview(mainImgv)
        
    }
    
    override func setContent(message: MTTMessageEntity) {
        super.setContent(message: message)
        
        let imageURL:String = self.imageURLFrom(message: message)
        
        self.mainImgv.setImage(str: imageURL)
        debugPrint("set content message imageURL:\(imageURL)")
    }

    override func layoutContentView(message: MTTMessageEntity) {
        
        self.mainImgv.mas_remakeConstraints { (maker ) in
            maker?.left.mas_equalTo()(self.bubbleImgv.mas_left)?.offset()(self.bubbleLeftEdge())
            maker?.top.mas_equalTo()(self.bubbleImgv.mas_top)?.offset()(self.bubbleTopEdge())
            maker?.bottom.mas_equalTo()(self.bubbleImgv.mas_bottom)?.offset()(-self.bubbleBottomEdge())
            maker?.right.mas_equalTo()(self.bubbleImgv.mas_right)?.offset()(-self.bubbleRightEdge())
        }
        
//        let sizecontent = self.contentSizeFor(message: message)
//        self.mainImgv.mas_remakeConstraints { (maker ) in
//            maker?.left.mas_equalTo()(self.bubbleImgv.mas_left)?.offset()(self.bubbleLeftEdge())
//            maker?.top.mas_equalTo()(self.bubbleImgv.mas_top)?.offset()(self.bubbleTopEdge())
//            maker?.size.mas_equalTo()(sizecontent)
//        }
    }
    
    override func contentSizeFor(message: MTTMessageEntity) -> CGSize {
        var defaultSize:CGSize = .init(width: 100, height: 61.8)  //默认 0.618 黄金比例
        
        let imageURL:String = self.imageURLFrom(message: message)
 
        var theImage:UIImage?
        if FileManager.default.fileExists(atPath: imageURL){
            theImage = UIImage.init(contentsOfFile: imageURL)
        }else{
            guard let url = URL.init(string: imageURL)else{
                return defaultSize
            }
            guard SDWebImageManager.shared().cachedImageExists(for: url) else{
                return defaultSize
            }
            guard let key = SDWebImageManager.shared().cacheKey(for: url)else {
                return defaultSize
            }
            guard let image = SDImageCache.shared().imageFromDiskCache(forKey: key)else {
                return defaultSize
            }
            
            theImage = image
        }
        guard (theImage != nil) else {
            return defaultSize
        }
        
        defaultSize.width = min( max(theImage!.size.width, 40),maxChatContentWidth * 0.618 )  // 至少40 的宽度

        defaultSize.height = defaultSize.width * theImage!.size.height/theImage!.size.width  //确定宽度后、根据图片的宽高比例来计算高度

        return defaultSize
    }

    
    private func imageURLFrom(message:MTTMessageEntity)->String{
    
        let contentDic = NSDictionary.initWithJsonString(message.msgContent) ?? [:]
        var imageURL:String = contentDic[MTTMessageEntity.DD_IMAGE_LOCAL_KEY] as? String ?? ""
        if imageURL.length <= 0 {
            imageURL = contentDic[MTTMessageEntity.DD_IMAGE_URL_KEY] as? String ?? ""
        }
        
        
        if imageURL.length > 0{
            imageURL = imageURL.replacingOccurrences(of: DD_MESSAGE_IMAGE_PREFIX, with: "")
            imageURL = imageURL.replacingOccurrences(of: DD_MESSAGE_IMAGE_SUFFIX, with: "")
        }
        return imageURL
    }
}

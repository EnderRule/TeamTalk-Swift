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
    
    deinit {
        mainImgv.removeObserver(self , forKeyPath: "image")
    }
    override func setupCustom() {
        super.setupCustom()
        
        mainImgv.contentMode = .scaleAspectFit
        mainImgv.backgroundColor = UIColor.clear
        
        mainImgv.addObserver(self , forKeyPath: "image", options: [.new,.old] , context: nil )
        
        self.contentView.addSubview(mainImgv)
    }
    
    override func setContent(message: MTTMessageEntity) {
        super.setContent(message: message)
        
        if message.isImageMessage{
            let imageURL:String = self.imageURLFrom(message: message)
            self.mainImgv.setImage(str: imageURL)
            debugPrint("set content message imageURL:\(imageURL)")
        }
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
        
        var scale:CGFloat = CGFloat(JSON.init(message.info)[MTTMessageEntity.kImageScale].floatValue)
        if scale == 0 {
            scale = 1.618   //寬高比 默认 0.618 黄金比例
        }
        
        let maxImgvWidth:CGFloat = maxChatContentWidth/2
        let minImgvWidth:CGFloat = 64
        
        var defaultSize:CGSize = .init(width: maxImgvWidth, height: maxImgvWidth / scale)
        
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
        
        if theImage != nil {
            defaultSize.width = min( max(theImage!.size.width, minImgvWidth),maxImgvWidth/scale )
            defaultSize.height = defaultSize.width * theImage!.size.height/theImage!.size.width  //计算好宽度后、根据图片的宽高比例来计算高度
            return defaultSize
        }

        return defaultSize
    }

    
    private func imageURLFrom(message:MTTMessageEntity)->String{
        
//        print("imageURLFrom(message ",message.info as NSDictionary)
        
        var imageURL:String = message.info[MTTMessageEntity.kImageLocalPath] as? String ?? ""
        imageURL = imageURL.safeLocalPath()
        if FileManager.default.fileExists(atPath: imageURL){
            return imageURL
        }
        return message.info[MTTMessageEntity.kImageUrl] as? String ?? ""
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if( object as? UIImageView) == mainImgv && keyPath == "image"{
            let newimage = change?[.newKey] as? UIImage
            let oldImage = change?[.oldKey] as? UIImage
            
            if newimage != oldImage && (newimage?.size.width ?? 0) > 0{
                self.cellReloadAsTableview()
            }
        }
    }
}

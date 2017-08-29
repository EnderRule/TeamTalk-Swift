//
//  HMChatVoiceCell.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class HMChatVoiceCell: HMChatBaseCell {

    var voiceImgv:UIImageView = UIImageView.init()
    var voiceDurationLabel:UILabel = UILabel.init()
    
    override func setupCustom() {
        super.setupCustom()
        
        voiceImgv.contentMode = .right
        
        voiceImgv.addCommonTap(target: self , sel: #selector(self.voicePlayOrStop))
        
        
        voiceDurationLabel.font = fontDetail
        
        voiceImgv.backgroundColor = UIColor.clear
        voiceDurationLabel.backgroundColor = UIColor.clear
        
        self.contentView.addSubview(voiceImgv)
        
        self.contentView.addSubview(voiceDurationLabel)
        
        voiceImgv.mas_makeConstraints { (maker ) in
            maker?.left.mas_equalTo()(self.bubbleImgv.mas_left)
            maker?.right.mas_equalTo()(self.bubbleImgv.mas_right)
            maker?.top.mas_equalTo()(self.bubbleImgv.mas_top)
            maker?.bottom.mas_equalTo()(self.bubbleImgv.mas_bottom)
        }
    }
    
    override func setContent(message: MTTMessageEntity) {
        super.setContent(message: message)
        
        let json = JSON.init(message.info)
        let hadPlayed:Bool = json[MTTMessageEntity.DDVOICE_PLAYED].boolValue
        self.showRedDot(show: !hadPlayed)
        let duration:Int = json[MTTMessageEntity.VOICE_LENGTH].intValue
        let durationString = "\(duration)‘’"
        self.voiceDurationLabel.text = durationString
        
        if self.bubbleLocation == .right {
            voiceImgv.contentMode = .right
            voiceImgv.image = #imageLiteral(resourceName: "dd_right_voice_three")
            
            voiceDurationLabel.textAlignment = .right
            voiceDurationLabel.mas_remakeConstraints({ (maker ) in
                maker?.left.mas_equalTo()(self.bubbleImgv.mas_right)?.offset()(-5)
                maker?.top.mas_equalTo()(self.voiceImgv.mas_top)
                maker?.bottom.mas_equalTo()(self.voiceImgv.mas_bottom)
                maker?.width.mas_equalTo()(50)
            })
        }else{
            voiceImgv.contentMode = .left
            voiceImgv.image = #imageLiteral(resourceName: "dd_left_voice_three")
            
            voiceDurationLabel.textAlignment = .left
            voiceDurationLabel.mas_remakeConstraints({ (maker ) in
                maker?.right.mas_equalTo()(self.bubbleImgv.mas_left)?.offset()(5)
                maker?.top.mas_equalTo()(self.voiceImgv.mas_top)
                maker?.bottom.mas_equalTo()(self.voiceImgv.mas_bottom)
                maker?.width.mas_equalTo()(50)
            })
        }
    }
    
    override func contentSizeFor(message: MTTMessageEntity) -> CGSize {
        let minWidth:CGFloat = maxChatContentWidth * 0.2
        let maxWidth:CGFloat = maxChatContentWidth * 0.6
        
        let json = JSON.init(message.info)
        let duration:CGFloat = CGFloat(json[MTTMessageEntity.VOICE_LENGTH].floatValue)
        let extraWidth:CGFloat = duration/60.0 * (maxWidth - minWidth)
        
        var defaultSize:CGSize = .init(width: minWidth, height: 40)
        defaultSize.width += extraWidth
        defaultSize.width = min(defaultSize.width, maxWidth)
        return defaultSize
    }
    
    private func showRedDot(show:Bool){
        let layerName:String = "RedDotLayer"
        voiceDurationLabel.subLayerFor(name: layerName)?.removeFromSuperlayer()

        if show {
            let redDotWidth:CGFloat = 12.0
            let redDotX:CGFloat = self.bubbleLocation == .right ? 46 : 2
            
            let redDotLayer:CALayer = CALayer.init()
            redDotLayer.frame = .init(x: redDotX, y: 2, width: redDotWidth, height: redDotWidth)
            redDotLayer.name = "RedDotLayer"
            redDotLayer.cornerRadius = redDotWidth/2.0
            redDotLayer.backgroundColor = UIColor.red.cgColor
            
            voiceDurationLabel.layer.addSublayer(redDotLayer)
        }
    }
    
    func voicePlayOrStop(){
        self.message?.info.updateValue(true , forKey: MTTMessageEntity.DDVOICE_PLAYED)
        self.showRedDot(show: false )
        
        if self.bubbleLocation == .right{
            voiceImgv.image = UIImage.animatedImage(with: [#imageLiteral(resourceName: "dd_right_voice_one"),#imageLiteral(resourceName: "dd_right_voice_two"),#imageLiteral(resourceName: "dd_right_voice_three")], duration: 1)
        }else {
            voiceImgv.image = UIImage.animatedImage(with: [#imageLiteral(resourceName: "dd_left_voice_one"),#imageLiteral(resourceName: "dd_left_voice_two"),#imageLiteral(resourceName: "dd_left_voice_three")], duration: 1)
        }
        
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}


extension UIView {
    func subLayerFor(name:String)->CALayer?{
        for sublayer in self.layer.sublayers ?? [] {
            if sublayer.name == name{
                return sublayer
            }
        }
        return nil
    }
}

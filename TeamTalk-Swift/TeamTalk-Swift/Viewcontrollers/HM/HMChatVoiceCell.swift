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
    
    var isVoicePlaying:Bool = false
    
    override func setupCustom() {
        super.setupCustom()
        
        voiceImgv.contentMode = .right
        voiceImgv.addCommonTap(target: self , sel: #selector(self.voicePlayOrStop))
        
        voiceDurationLabel.font = fontNormal
        
        voiceImgv.backgroundColor = UIColor.clear
        voiceDurationLabel.backgroundColor = UIColor.clear
        
        self.contentView.addSubview(voiceImgv)
        
        self.contentView.addSubview(voiceDurationLabel)
        
        voiceImgv.mas_makeConstraints { (maker ) in
            maker?.left.mas_equalTo()(self.bubbleImgv.mas_left)?.offset()(15)
            maker?.right.mas_equalTo()(self.bubbleImgv.mas_right)?.offset()(-15)
            maker?.top.mas_equalTo()(self.bubbleImgv.mas_top)
            maker?.bottom.mas_equalTo()(self.bubbleImgv.mas_bottom)
        }
    }
    
    override func setContent(message: MTTMessageEntity) {
        super.setContent(message: message)
        
        let json = JSON.init(message.info)
        let hadPlayed:Bool = json[MTTMessageEntity.kVoiceHadPlayed].boolValue
        self.showRedDot(show: !hadPlayed && !message.isSendBySelf)
        
        let duration:Int = json[MTTMessageEntity.kVoiceLength].intValue
        let durationString = "\(duration)''"
        self.voiceDurationLabel.text = durationString
        
        if self.bubbleLocation == .right {
            voiceImgv.contentMode = .right
            voiceImgv.image = #imageLiteral(resourceName: "dd_right_voice_three")
            
            voiceDurationLabel.textAlignment = .right
            voiceDurationLabel.mas_remakeConstraints({ (maker ) in
                maker?.right.mas_equalTo()(self.bubbleImgv.mas_left)?.offset()(-8)
                maker?.top.mas_equalTo()(self.voiceImgv.mas_top)
                maker?.bottom.mas_equalTo()(self.voiceImgv.mas_bottom)
                maker?.width.mas_equalTo()(40)
            })
            
            
            activityView.mas_remakeConstraints({ (maker ) in
                maker?.right.mas_equalTo()(self.voiceDurationLabel.mas_left)
                maker?.bottom.mas_equalTo()(self.bubbleImgv.mas_bottom)

            })
            resendButton.mas_remakeConstraints({ (maker ) in
                maker?.right.mas_equalTo()(self.voiceDurationLabel.mas_left)
                maker?.bottom.mas_equalTo()(self.bubbleImgv.mas_bottom)

            })
            
        }else{
            voiceImgv.contentMode = .left
            voiceImgv.image = #imageLiteral(resourceName: "dd_left_voice_three")
            
            voiceDurationLabel.textAlignment = .left
            voiceDurationLabel.mas_remakeConstraints({ (maker ) in
                maker?.left.mas_equalTo()(self.bubbleImgv.mas_right)?.offset()(8)
                maker?.top.mas_equalTo()(self.voiceImgv.mas_top)
                maker?.bottom.mas_equalTo()(self.voiceImgv.mas_bottom)
                maker?.width.mas_equalTo()(40)
            })
            
            activityView.mas_remakeConstraints({ (maker ) in
                maker?.left.mas_equalTo()(self.voiceDurationLabel.mas_right)
                maker?.bottom.mas_equalTo()(self.bubbleImgv.mas_bottom)

            })
            resendButton.mas_remakeConstraints({ (maker ) in
                maker?.left.mas_equalTo()(self.voiceDurationLabel.mas_right)
                maker?.bottom.mas_equalTo()(self.bubbleImgv.mas_bottom)

            })
        }
        
    }
    
    override func contentSizeFor(message: MTTMessageEntity) -> CGSize {
        let minWidth:CGFloat = maxChatContentWidth * 0.2
        let maxWidth:CGFloat = maxChatContentWidth * 0.6
        
        let json = JSON.init(message.info)
        let duration:CGFloat = CGFloat(json[MTTMessageEntity.kVoiceLength].floatValue)
        let extraWidth:CGFloat = duration/60.0 * (maxWidth - minWidth)
        
        var defaultSize:CGSize = .init(width: minWidth, height: 30)
        defaultSize.width += extraWidth
        defaultSize.width = min(defaultSize.width, maxWidth)
        return defaultSize
    }
    
    private func showRedDot(show:Bool){
        let layerName:String = "RedDotLayer"
        voiceDurationLabel.subLayerFor(name: layerName)?.removeFromSuperlayer()

        if show {
            let redDotWidth:CGFloat = 8.0
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
        self.showRedDot(show: false )

        if self.message != nil {
            self.message!.info.updateValue(true , forKey: MTTMessageEntity.kVoiceHadPlayed)
            self.message!.updateToDB(compeletion: nil )
            
            self.delegate?.HMChatCellAction(type: .voicePlayOrStop, message: self.message!, sourceView: self)
        }
    }
    
    public func updatePlayState(isPlaying:Bool){
        
        if isPlaying {
            if self.bubbleLocation == .right{
                voiceImgv.image = UIImage.animatedImage(with: [#imageLiteral(resourceName: "dd_right_voice_one"),#imageLiteral(resourceName: "dd_right_voice_two"),#imageLiteral(resourceName: "dd_right_voice_three")], duration: 1)
            }else {
                voiceImgv.image = UIImage.animatedImage(with: [#imageLiteral(resourceName: "dd_left_voice_one"),#imageLiteral(resourceName: "dd_left_voice_two"),#imageLiteral(resourceName: "dd_left_voice_three")], duration: 1)
            }
        }else{
            if self.bubbleLocation == .right{
                voiceImgv.image = #imageLiteral(resourceName: "dd_right_voice_three")
            }else {
                voiceImgv.image = #imageLiteral(resourceName: "dd_left_voice_three")
            }
        }
    }
    

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

extension String {
    func safeLocalPath()->String{
        
        let range:NSRange = (self as NSString).range(of: "/var/mobile/Containers/Data/Application/")
        if range.length > 0{
            
            var newfilePath = self
            if FileManager.default.fileExists(atPath: newfilePath){
                return newfilePath
            }else {
                newfilePath  = (newfilePath as NSString).substring(from: range.location+range.length+36)
                
                newfilePath = NSHomeDirectory().appending(newfilePath)
                
                return newfilePath
            }
        }else{
            return self
        }
        
    }
}

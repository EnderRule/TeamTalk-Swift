//
//  HMChatBaseCell.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/22.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

enum HMBubbleLocation:Int {
    case none = 0
    case left = 1
    case right = 2
}

let HMAvatarGap:CGFloat       = 8   // //头像到边缘的距离
let HMBubbleUpDownGap:CGFloat = 15  // 气泡到上下边缘的距离
let HMBubbleAvatarGap:CGFloat = 15  // 头像和气泡之间的距离



enum HMChatCellActionType:Int{
    case none       = 0
    case sendAgain  = 1
    case showMenu   = 2
    case showSender = 4
    case voicePlay  = 8
    case voiceStop  = 16
    case delete     = 32
}

protocol HMChatCellActionDelegate {
    func HMChatAction(type:HMChatCellActionType,message:MTTMessageEntity,sourceView:UIView?) -> Void
}

//不可直接使用，需由子类继承再使用
class HMChatBaseCell: HMBaseCell {

    var avatarImgv:UIImageView = UIImageView.init()
    var nameLabel:UILabel = UILabel.init()
    
    var bubbleImgv:UIImageView = UIImageView.init()
    var resendButton:UIButton = UIButton.init(type: .system)
    var activityView:UIActivityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
    var bubbleLocation:HMBubbleLocation = .none
    var session:MTTSessionEntity? // = MTTSessionEntity.init()
    var message:MTTMessageEntity?
    var delegate:HMChatCellActionDelegate?
    
    deinit {
        self.session = nil
        self.message = nil
        self.delegate = nil
    }
    
    
    override func setupCustom() {
        avatarImgv.backgroundColor = UIColor.blue
        
        nameLabel.font = fontNormal
        nameLabel.textColor = colorTitle
        nameLabel.backgroundColor = UIColor.clear
        
        bubbleImgv.contentMode = .scaleToFill
        
        self.activityView.hidesWhenStopped = true
        self.activityView.isHidden = true
        
        self.resendButton.setImage(UIImage.init(named: "setting"), for: .normal)
        self.resendButton.addTarget(self , action: #selector(self.sendAgainAction), for: .touchUpInside)
        
        self.contentView.addSubview(avatarImgv)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(bubbleImgv)
        self.contentView.addSubview(activityView)
        self.contentView.addSubview(resendButton)
        
        nameLabel.mas_makeConstraints { (maker ) in
            maker?.size.mas_equalTo()(CGSize.init(width: 200, height: 16))
            maker?.left.mas_equalTo()(self.avatarImgv.mas_right)?.offset()(HMAvatarGap)
            maker?.top.mas_equalTo()(0)
        }
        
    }
    
    
    func setContent(message: MTTMessageEntity) {
        self.message = message
        
        let leftConfig:MTTBubbleConfig = MTTBubbleModule.shareInstance().getBubbleConfigLeft(true)
        let rightConfig:MTTBubbleConfig = MTTBubbleModule.shareInstance().getBubbleConfigLeft(false)
        
        let size = self .sizeFor(message: message)
        let bubbleWidth:CGFloat = self.bubbleLeftEdge() + size.width + self.bubbleRightEdge()
        let bubbleHeight:CGFloat = self.bubbleTopEdge() + size.height + self.bubbleBottomEdge()
        
        //头像位置
        if message.senderId == RuntimeStatus.instance().user.userId {
            self.bubbleLocation = .right
            
            self.avatarImgv.mas_remakeConstraints({ (maker ) in
                maker?.right.equalTo()(self.contentView)?.offset()(-HMAvatarGap)
                maker?.size.equalTo()(CGSize.init(width: 40, height: 40))
                maker?.top.equalTo()(HMAvatarGap)
            })
        }else{
            self.bubbleLocation = .left
            
            self.avatarImgv.mas_remakeConstraints({ (maker ) in
                maker?.left.equalTo()(HMAvatarGap)
                maker?.size.equalTo()(CGSize.init(width: 40, height: 40))
                maker?.top.equalTo()(HMAvatarGap)
            })
        }
        
        //设置头像和昵称 
        DDUserModule.shareInstance().getUserForUserID(message.senderId) { (user ) in
            if user != nil {
                self.avatarImgv.setImage(str: user!.avatarUrl)
                self.nameLabel.text = user!.nick
            }
        }
        //是否隐藏昵称
        if self.bubbleLocation == .right || message.sessionType == .sessionTypeSingle{
            self.nameLabel.mas_updateConstraints({ (maker ) in
                maker?.height.mas_equalTo()(0)
            })
        }else{
            self.nameLabel.mas_updateConstraints({ (maker ) in
                maker?.height.equalTo()(16)
            })
        }
        
        //设置气泡位置
        if self.bubbleLocation == .right {
            
            self.bubbleImgv.mas_remakeConstraints({ (maker) in
                maker?.right.mas_equalTo()(self.avatarImgv.mas_left)?.offset()(-HMBubbleAvatarGap)
                maker?.top.mas_equalTo()(self.nameLabel.mas_bottom)
                maker?.size.mas_equalTo()(CGSize.init(width: bubbleWidth, height: bubbleHeight))
            })
            if var bubbleImage:UIImage = UIImage.init(named: rightConfig.textBgImage){
                bubbleImage = bubbleImage.stretchableImage(withLeftCapWidth: Int(rightConfig.stretchy.left), topCapHeight: Int(rightConfig.stretchy.top))
                self.bubbleImgv.image = bubbleImage
            }
        }else{
            self.bubbleImgv.mas_remakeConstraints({ (maker) in
                maker?.left.mas_equalTo()(self.avatarImgv.mas_right)?.offset()(HMBubbleAvatarGap)
                maker?.top.mas_equalTo()(self.nameLabel.mas_bottom)
                maker?.size.mas_equalTo()(CGSize.init(width: bubbleWidth, height: bubbleHeight))
            })
            if var bubbleImage:UIImage = UIImage.init(named: leftConfig.textBgImage){
                bubbleImage = bubbleImage.stretchableImage(withLeftCapWidth: Int(leftConfig.stretchy.left), topCapHeight: Int(leftConfig.stretchy.top))
                self.bubbleImgv.image = bubbleImage
            }

        }
        
        //设置菊花/重发按钮的位置
        if self.bubbleLocation == .right {
            self.activityView.mas_updateConstraints({ (maker ) in
                maker?.right.mas_equalTo()(self.bubbleImgv.mas_left)?.offset()(-10)
                maker?.bottom.mas_equalTo()(self.bubbleImgv.mas_bottom)
            })
            self.resendButton.mas_updateConstraints({ (maker ) in
                maker?.right.mas_equalTo()(self.bubbleImgv.mas_left)?.offset()(-10)
                maker?.bottom.mas_equalTo()(self.bubbleImgv.mas_bottom)
            })
            
        }else{
            self.activityView.mas_updateConstraints({ (maker ) in
                maker?.left.mas_equalTo()(self.bubbleImgv.mas_right)?.offset()(10)
                maker?.bottom.mas_equalTo()(self.bubbleImgv.mas_bottom)
            })
            self.resendButton.mas_updateConstraints({ (maker ) in
                maker?.left.mas_equalTo()(self.bubbleImgv.mas_right)?.offset()(10)
                maker?.bottom.mas_equalTo()(self.bubbleImgv.mas_bottom)
            })
        }
        
        //发送状态
        switch message.state {
        case .SendFailure:
            self.activityView.stopAnimating()
            self.resendButton.isHidden = false
            break
        case .SendSuccess:
            self.activityView.stopAnimating()
            self.resendButton.isHidden = true
            break
        case .Sending:
            self.activityView.startAnimating()
            self.resendButton.isHidden = true
            break
        }
        
        //内容位置
        self.layoutContentView(message: message)
    }
    
    func layoutContentView(message:MTTMessageEntity){
        
    }
 
    func sizeFor(message:MTTMessageEntity)->CGSize{
        return CGSize.init(width: 180, height: 90)
    }
    
    func bubbleTopEdge()->CGFloat {
        return 10
    }
    
    func bubbleLeftEdge()->CGFloat {
        return  15
    }
    func bubbleBottomEdge()->CGFloat{
        return 10
    }
    func bubbleRightEdge()->CGFloat{
        return 15
    }
    
    
    
    func sendAgainAction(){
        
    }
    
    func showSending(){
        
    }
    func showSendFailure(){
    
    }
    func showSendSuccess(){
    
    }
    

    
    
}

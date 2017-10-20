//
//  HMChatBaseCell.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/22.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

@objc public enum HMBubbleLocation:Int {
    case none = 0
    case left = 1
    case right = 2
}

let HMAvatarGap:CGFloat       = 8   // //头像到边缘的距离
let HMBubbleUpDownGap:CGFloat = 8  // 气泡到上下边缘的距离
let HMBubbleAvatarGap:CGFloat = 5  // 头像和气泡之间的距离

let maxChatContentWidth:CGFloat = (SCREEN_WIDTH() - 70.0 * 2.0)   //聊天cell的内容view的最大宽度
//字体大小
let fontTitle  = UIFont.systemFont(ofSize: 16)
let fontNormal = UIFont.systemFont(ofSize: 14)
let fontDetail = UIFont.systemFont(ofSize: 12)

@objc public  enum HMChatCellActionType:Int{
    case none       = 0
    case sendAgain  = 1
    case showMenu   = 2
    case showSender = 4
    case voicePlayOrStop  = 8

    case delete     = 32
}

@objc public protocol HMChatCellActionDelegate {
    func HMChatCellAction(type:HMChatCellActionType,message:MTTMessageEntity?,sourceView:UIView?) -> Void
}

//不可直接使用，需由子类继承再使用
public class HMChatBaseCell: HMBaseCell {

    public var avatarImgv:UIImageView = UIImageView.init()
    public var nameLabel:UILabel = UILabel.init()
    
    public var bubbleImgv:UIImageView = UIImageView.init()
    public var resendButton:UIButton = UIButton.init(type: .system)
    public var activityView:UIActivityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
    public var msgStateLb:UILabel = UILabel.init()
    
    public var bubbleLocation:HMBubbleLocation = .none
    public var session:MTTSessionEntity?
    public var message:MTTMessageEntity?
    public var delegate:HMChatCellActionDelegate?
    
    deinit {
        self.session = nil
        self.message = nil
        self.delegate = nil
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false , animated: false )
    }
    override public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(false , animated: false )
    }
    
    override public  func setupCustom() {
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        avatarImgv.backgroundColor = UIColor.clear
        
        nameLabel.font = fontNormal
        nameLabel.textColor = colorTitle
        nameLabel.backgroundColor = UIColor.clear
        
        bubbleImgv.contentMode = .scaleToFill
        
        self.activityView.hidesWhenStopped = true
        self.activityView.isHidden = true
        self.activityView.backgroundColor = UIColor.clear
        self.activityView.frame.size = .init(width: 20, height: 20)
        
        self.resendButton.setTitle("重新發送", for: .normal)
        self.resendButton.addTarget(self , action: #selector(self.sendAgainAction), for: .touchUpInside)
        self.resendButton.sizeToFit()
        
        msgStateLb.font = fontDetail
        msgStateLb.textColor = UIColor.white
        msgStateLb.layer.cornerRadius = 4.0
        msgStateLb.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        msgStateLb.isHidden = true
        msgStateLb.frame.size = CGSize.init(width: 30, height: 18)
        
        self.contentView.addSubview(avatarImgv)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(bubbleImgv)
        self.contentView.addSubview(activityView)
        self.contentView.addSubview(resendButton)
        self.contentView.addSubview(msgStateLb)
        
        nameLabel.mas_makeConstraints { (maker ) in
            maker?.size.mas_equalTo()(CGSize.init(width: 200, height: 16))
            maker?.left.mas_equalTo()(self.avatarImgv.mas_right)?.offset()(HMAvatarGap)
            maker?.top.mas_equalTo()(0)
        }
    }
    
    
    public func setContent(message: MTTMessageEntity) {
        self.message = message
        
        
        let size = self .contentSizeFor(message: message)
        let bubbleWidth:CGFloat = self.bubbleLeftEdge() + size.width + self.bubbleRightEdge()
        let bubbleHeight:CGFloat = self.bubbleTopEdge() + size.height + self.bubbleBottomEdge()
        
        //头像位置
        if message.senderId == HMLoginManager.shared.currentUser.userId  {
            self.bubbleLocation = .right
            
            self.avatarImgv.mas_remakeConstraints({ (maker ) in
                maker?.top.equalTo()(HMAvatarGap)
                maker?.right.equalTo()(self.contentView.mas_right)?.offset()(-HMAvatarGap)
                
                maker?.size.equalTo()(CGSize.init(width: 40, height: 40))
            })
        }else{
            self.bubbleLocation = .left
            
            self.avatarImgv.mas_remakeConstraints({ (maker ) in
                maker?.top.equalTo()(HMAvatarGap)
                maker?.left.equalTo()(HMAvatarGap)
                
                maker?.size.equalTo()(CGSize.init(width: 40, height: 40))
            })
        }
        
        //设置头像和昵称 
        if let sender:MTTUserEntity = HMUsersManager.shared.userFor(ID: message.senderId){
            self.avatarImgv.setImage(str: sender.avatar, placeHolder:#imageLiteral(resourceName: "defaultAvatar"))
            self.nameLabel.text = sender.nickName
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
                maker?.top.mas_equalTo()(self.nameLabel.mas_bottom)?.offset()(HMBubbleUpDownGap)
                maker?.size.mas_equalTo()(CGSize.init(width: bubbleWidth, height: bubbleHeight))
            })
            let rightConfig:MTTBubbleConfig = MTTBubbleModule.shareInstance().getBubbleConfigLeft(false)
            if var bubbleImage:UIImage = UIImage.init(named: rightConfig.textBgImage){
                bubbleImage = bubbleImage.stretchableImage(withLeftCapWidth: Int(rightConfig.stretchy.left), topCapHeight: Int(rightConfig.stretchy.top))
                self.bubbleImgv.image = bubbleImage
            }
        }else{
            self.bubbleImgv.mas_remakeConstraints({ (maker) in
                maker?.left.mas_equalTo()(self.avatarImgv.mas_right)?.offset()(HMBubbleAvatarGap)
                maker?.top.mas_equalTo()(self.nameLabel.mas_bottom)?.offset()(HMBubbleUpDownGap)
                maker?.size.mas_equalTo()(CGSize.init(width: bubbleWidth, height: bubbleHeight))
            })
            let leftConfig:MTTBubbleConfig = MTTBubbleModule.shareInstance().getBubbleConfigLeft(true)
            if var bubbleImage:UIImage = UIImage.init(named: leftConfig.textBgImage){
                bubbleImage = bubbleImage.stretchableImage(withLeftCapWidth: Int(leftConfig.stretchy.left), topCapHeight: Int(leftConfig.stretchy.top))
                self.bubbleImgv.image = bubbleImage
            }

        }
        
        //设置菊花/重发按钮的位置
        if self.bubbleLocation == .right {
            self.activityView.mas_remakeConstraints({ (maker ) in
                maker?.right.mas_equalTo()(self.bubbleImgv.mas_left)?.offset()(-10)
                maker?.bottom.mas_equalTo()(self.bubbleImgv.mas_bottom)
            })
            self.resendButton.mas_remakeConstraints({ (maker ) in
                maker?.right.mas_equalTo()(self.bubbleImgv.mas_left)?.offset()(-10)
                maker?.bottom.mas_equalTo()(self.bubbleImgv.mas_bottom)
            })
            self.msgStateLb.mas_remakeConstraints({ (maker ) in
                maker?.right.mas_equalTo()(self.bubbleImgv.mas_left)?.offset()(-10)
                maker?.bottom.mas_equalTo()(self.bubbleImgv.mas_bottom)
            })
            self.msgStateLb.textAlignment = .right
        }else{
            self.activityView.mas_remakeConstraints({ (maker ) in
                maker?.left.mas_equalTo()(self.bubbleImgv.mas_right)?.offset()(10)
                maker?.bottom.mas_equalTo()(self.bubbleImgv.mas_bottom)
            })
            self.resendButton.mas_remakeConstraints({ (maker ) in
                maker?.left.mas_equalTo()(self.bubbleImgv.mas_right)?.offset()(10)
                maker?.bottom.mas_equalTo()(self.bubbleImgv.mas_bottom)
            })
            self.msgStateLb.mas_remakeConstraints({ (maker ) in
                maker?.left.mas_equalTo()(self.bubbleImgv.mas_right)?.offset()(10)
                maker?.bottom.mas_equalTo()(self.bubbleImgv.mas_bottom)
            })
            self.msgStateLb.textAlignment = .left
        }
        
        self.updateSendState(state:message.state)
        
        //内容位置
        self.layoutContentView(message: message)
    }
    
    public func cellHeightFor(message:MTTMessageEntity)->CGFloat{
        // 昵称高度 + 实际内容高度 + 气泡与cell的间隔 + 气泡与内容的间隔。 总高度必须 >= 头像高度 + 头像与cell的间隔
        var nameHeight:CGFloat = nameLabel.height
        if message.sessionType == .sessionTypeSingle || message.senderId == HMLoginManager.shared.currentUser.userId {
            nameHeight = 0
        }
        
        var contentSize:CGSize = self.contentSizeFor(message: message)
        if message.msgContentType == .Text  {
            let cell = HMChatTextCell.init(style: .default, reuseIdentifier: HMChatTextCell.cellIdentifier )
            contentSize = cell.contentSizeFor(message: message)
        }else if message.msgContentType == .Image {
            let cell = HMChatImageCell.init(style: .default, reuseIdentifier: HMChatImageCell.cellIdentifier )
            contentSize = cell.contentSizeFor(message: message)
        }else if message.msgContentType == .Audio || message.msgContentType == .GroupAudio {
            
        }else if message.msgContentType == .Voice{
            let cell = HMChatVoiceCell.init(style: .default, reuseIdentifier: HMChatVoiceCell.cellIdentifier )
            contentSize = cell.contentSizeFor(message: message)
        }else if message.msgContentType == .Emotion {
            contentSize = .init(width: 150, height: 150)
        }
        
        let totalHeight = nameHeight + contentSize.height + self.bubbleTopEdge() + self.bubbleBottomEdge() + HMBubbleUpDownGap * 2.0
        
        return max(totalHeight, avatarImgv.height + HMAvatarGap * 2)
    }
    
    
    ///子类继承实现
    public func layoutContentView(message:MTTMessageEntity){
        
    }
    
    public func contentSizeFor(message:MTTMessageEntity)->CGSize{
        return CGSize.init(width: 180, height: 44.0)
    }
    
    public func bubbleTopEdge()->CGFloat {
        return 6
    }
    
    public func bubbleLeftEdge()->CGFloat {
        if self.bubbleLocation == .right{
            return 5
        }else {
            return 10
        }
    }
    public func bubbleBottomEdge()->CGFloat{
        return 5
    }
    public func bubbleRightEdge()->CGFloat{
        if self.bubbleLocation == .right{
            return 10
        }else {
            return 5
        }
    }
    
    
    public func sendAgainAction(){
        if self.message != nil {
            self.updateSendState(state: .Sending)
            self.delegate?.HMChatCellAction(type: .sendAgain, message: self.message, sourceView: self )
        }
    }
    
    //发送状态
    private  func updateSendState(state:DDMessageState){
        self.resendButton.isHidden = true
        self.activityView.stopAnimating()
        self.msgStateLb.isHidden = true

        switch state {
        case .SendFailure:
            self.resendButton.isHidden = false
            break
        case .SendSuccess:
            break
        case .Sending:
            self.activityView.startAnimating()
            break
        case .UnRead:
            if self.bubbleLocation == .right{
                self.msgStateLb.isHidden = false
                self.msgStateLb.text = "未读"
            }
            break
        case .Readed:
            if self.bubbleLocation == .right{
                self.msgStateLb.isHidden = false
                self.msgStateLb.text = "已读"
            }
        }
    }
 

    
    
}

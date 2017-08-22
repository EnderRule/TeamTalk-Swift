//
//  HMRecentSessionCell.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class HMRecentSessionCell: HMBaseCell {

    var session:MTTSessionEntity?
    
    var avatarView:MTTAvatarImageView = MTTAvatarImageView.init()// UIImageView.init()
    var nameLabel:UILabel = UILabel.init()
    
    var msgLabel:UILabel = UILabel.init()
    var dateLabel:UILabel = UILabel.init()
    var unreadMsgLabel:UILabel = UILabel.init()
    
    
    static let cellHeight:CGFloat = 64.0
    
    override func setupCustom(){
        avatarView.contentMode = .scaleAspectFit
        
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.textColor = colorTitle
        
        msgLabel.font = UIFont.systemFont(ofSize: 14)
        msgLabel.textColor = colorNormal
        
        
        dateLabel.font = UIFont.systemFont(ofSize: 13)
        dateLabel.textAlignment = .right
        
        unreadMsgLabel.font = UIFont.systemFont(ofSize: 12)
        unreadMsgLabel.textColor = UIColor.white
        unreadMsgLabel.backgroundColor  = UIColor.red
        unreadMsgLabel.add(corners: .allCorners, radius: CGSize.init(width: 8, height: 8))
        unreadMsgLabel.textAlignment = .center
        
        self.contentView.addSubview(avatarView)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(msgLabel)
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(unreadMsgLabel)
        
        avatarView.frame = .init(x: defaultPaddingWidth, y: defaultPaddingWidth, width: 64 - defaultPaddingWidth * 2, height: 64 - defaultPaddingWidth * 2)
        
        dateLabel.mas_makeConstraints { (maker) in
            maker?.right.equalTo()(self.contentView.mas_right)?.offset()(-defaultPaddingWidth)
            maker?.top.equalTo()(defaultPaddingWidth/2)
            maker?.width.equalTo()(120)
            maker?.height.equalTo()(20)
        }
        
        nameLabel.mas_makeConstraints { (maker ) in
            maker?.right.mas_equalTo()(self.dateLabel)
            maker?.left.mas_equalTo()(self.avatarView.mas_right)?.offset()(10)
            maker?.top.equalTo()(defaultPaddingWidth/2)
            maker?.height.equalTo()(28)
        }
        msgLabel.mas_makeConstraints { (maker ) in
            maker?.left.equalTo()(self.nameLabel.mas_left)
            maker?.top.equalTo()(self.nameLabel.mas_bottom)
            maker?.width.equalTo()(self.nameLabel.mas_width)
            maker?.height.equalTo()(18)
        }
        unreadMsgLabel.mas_makeConstraints { (maker ) in
            maker?.centerY.equalTo()(self.contentView.mas_centerY)
            maker?.right.equalTo()(self.contentView.mas_right)?.offset()(-10)
            maker?.width.equalTo()(100)
            maker?.height.equalTo()(16)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
    
    
    override func configWith(object: Any) {
        
        if let session = object as? MTTSessionEntity {
            self.session = session
            
            self.avatarView.setImage(str: "setting")
            
            self.nameLabel.text = session.name.appending("  (ID:\(session.sessionID))")
            
            let thedate = Date.init(timeIntervalSince1970: session.timeInterval)
            self.dateLabel.text = (thedate as NSDate).transformToFuzzyDate() //"\(sss.timeInterval)"
            if session.lastMsg.hasPrefix(DD_MESSAGE_IMAGE_PREFIX){
                self.msgLabel.text = "[圖片]"
            }else if session.lastMsg.hasSuffix(".spx"){
                self.msgLabel.text = "[語音]"
            }else{
                self.msgLabel.text = session.lastMsg
            }
            self.updateUnread(count: session.unReadMsgCount)
            
            self.unreadMsgLabel.backgroundColor = UIColor.red

            if session.isGroupSession {
                //configs for GroupEntity

                DDGroupModule.instance().getGroupInfogroupID(session.sessionID, completion: { (group ) in
                    if group != nil {
                        self.nameLabel.text = group!.name

                        if group!.isShield{
                            self.unreadMsgLabel.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
                        }else{
                            self.unreadMsgLabel.backgroundColor = UIColor.red
                        }
                        
                        var avatars:[String] = []
                        let UIDs:[String] = group!.groupUserIds.reversed()
                        for uid in UIDs{
                            if  UIDs.index(of: uid) ?? 0 > 8 {
                                break
                            }
                            DDUserModule.shareInstance().getUserForUserID(uid , block: { (user ) in
                                if user != nil {
                                    avatars.append(user!.avatarUrl)
                                }
                            })
                        }
                        let groupAvatarUrls = (avatars as NSArray).componentsJoined(by: ";")
                        self.avatarView.setAvatar(groupAvatarUrls, group: true )
                    }
                })
            }else {
                //configs for UserEntity
                DDUserModule.shareInstance().getUserForUserID(session.sessionID, block: { (user) in
                    if user != nil {
                        for subview in self.avatarView.subviews{
                            subview.removeFromSuperview()
                        }
                        self.avatarView.image = nil
                        
                        self.avatarView.setAvatar(user!.avatarUrl, group: false)
                    }
                })
                
            }
        }
        
    }
    
    
    private func updateUnread(count:Int){
        if count <= 0{
            self.unreadMsgLabel.isHidden = true
            return ;
        }
        
        self.unreadMsgLabel.isHidden = false

        var width:CGFloat = 16.0
        if count < 10 {
            self.unreadMsgLabel.text = "\(count)"
            width = 16.0
        }else if count < 100 {
            self.unreadMsgLabel.text = "\(count)"
            width = 25.0
        }else  {
            self.unreadMsgLabel.text = "99+"
            width = 34
        }
//        let newsize = unreadMsgLabel.sizeThatFits(CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: unreadMsgLabel.height))
        unreadMsgLabel.mas_updateConstraints { (maker ) in
            maker?.width.equalTo()(width)
        }
    }
    
}

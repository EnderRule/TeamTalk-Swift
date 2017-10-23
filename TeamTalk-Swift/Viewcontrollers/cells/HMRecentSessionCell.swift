//
//  HMRecentSessionCell.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

public class HMRecentSessionCell: HMBaseCell {

    public var session:MTTSessionEntity?
    
    public var avatarView:UIImageView = UIImageView.init()
    public var nameLabel:UILabel = UILabel.init()
    
    public var msgLabel:UILabel = UILabel.init()
    public var dateLabel:UILabel = UILabel.init()
    public var unreadMsgLabel:UILabel = UILabel.init()
    
    
    public  static let cellHeight:CGFloat = 64.0
    
    override public func setupCustom(){
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
        unreadMsgLabel.textAlignment = .center
        
        self.contentView.addSubview(avatarView)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(msgLabel)
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(unreadMsgLabel)
        
        let avatarWidth = HMRecentSessionCell.cellHeight - defaultPaddingWidth * 2
        avatarView.frame = .init(x: defaultPaddingWidth, y: defaultPaddingWidth, width: avatarWidth, height: avatarWidth)
        
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
//        unreadMsgLabel.mas_makeConstraints { (maker ) in
//            maker?.centerY.equalTo()(self.contentView.mas_centerY)
//            maker?.right.equalTo()(self.contentView.mas_right)?.offset()(-10)
//            maker?.width.equalTo()(26)
//            maker?.height.equalTo()(16)
//        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if !unreadMsgLabel.isHidden{
            unreadMsgLabel.fr_height = 16
            unreadMsgLabel.fr_centerY = self.contentView.fr_centerY + 8
            unreadMsgLabel.fr_right = self.contentView.fr_right - 10
            
            //Warning:使用这种方式设置圆角、将不能用 masnory 约束布局
            unreadMsgLabel.add(corners: .allCorners, radius: CGSize.init(width: 8, height: 8))
        }
    }
    
    
    override public func configWith(object: Any) {
        
        if let session = object as? MTTSessionEntity {
            self.session = session
            
            self.nameLabel.text = session.name.appending("  (ID:\(session.sessionID))")
            
            let thedate = Date.init(timeIntervalSince1970: session.timeInterval)
            self.dateLabel.text = (thedate as NSDate).transformToFuzzyDate()
            
            self.msgLabel.text = session.lastMsg
            self.updateUnread(count: session.unReadMsgCount)
            
            self.unreadMsgLabel.backgroundColor = UIColor.red

            if session.isGroupSession {
                //configs for GroupEntity

                if let group = HMGroupsManager.shared.groupFor(ID: session.sessionID){
                    self.nameLabel.text = group.name
                    
                    if group.isShield{
                        self.unreadMsgLabel.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
                    }else{
                        self.unreadMsgLabel.backgroundColor = UIColor.red
                    }
                    
                    var avatars:[String] = []
                    let UIDs:[String] = group.groupUserIds.reversed()
                    for uid in UIDs{
                        if  UIDs.index(of: uid) ?? 0 > 8 {
                            break
                        }
                        if let user:MTTUserEntity = HMUsersManager.shared.userFor(ID: uid){
                            avatars.append(user.avatar)
                        }
                    }
                    //                        let groupAvatarUrls = (avatars as NSArray).componentsJoined(by: ";")
                    self.avatarView.setImage(str: avatars.first ?? "")//.setAvatar(groupAvatarUrls, group: true )
                    
                }
            }else {
                //configs for UserEntity
                if let user:MTTUserEntity = HMUsersManager.shared.userFor(ID: session.sessionID){
                    for subview in self.avatarView.subviews{
                        subview.removeFromSuperview()
                    }
                    self.avatarView.image = nil
                    self.avatarView.setImage(str: user.avatar)
                }
                
            }
        }
        
    }
    
    
    private func updateUnread(count:Int){
        
        guard count > 0 else {
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
        unreadMsgLabel.fr_width = width
    }
    
}

//
//  HMContactsCell.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/24.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class HMContactsCell: HMBaseCell {

    var avatarImgv:MTTAvatarImageView = MTTAvatarImageView.init()
    var nameLabel:M80AttributedLabel = M80AttributedLabel.init()
    override func setupCustom() {
        
        
        avatarImgv.contentMode = .scaleAspectFit
        avatarImgv.backgroundColor = UIColor.red
        self.contentView.addSubview(avatarImgv)
        
        nameLabel.font = fontTitle
        nameLabel.textColor = colorTitle
        self.contentView.addSubview(nameLabel)
        
        
        avatarImgv.mas_makeConstraints { (maker ) in
            maker?.top.mas_equalTo()(self.contentView.mas_top)?.offset()(HMAvatarGap)
            maker?.left.mas_equalTo()(self.contentView.mas_left)?.offset()(HMAvatarGap)
            maker?.width.mas_equalTo()(40)
            maker?.height.mas_equalTo()(40)
            
        }
        
        nameLabel.mas_makeConstraints { (maker ) in
            maker?.left.mas_equalTo()(self.avatarImgv.mas_right)?.offset()(HMAvatarGap)
            maker?.top.mas_equalTo()(self.contentView.mas_top)
            maker?.right.mas_equalTo()(self.contentView.mas_right)
            maker?.bottom.mas_equalTo()(self.contentView.mas_bottom)
        }
        
    }
    
    override func configWith(object: Any) {
        if let user = object as? MTTUserEntity {
            avatarImgv.setAvatar(user.avatar, group: false )
            nameLabel.text = user.name
        }else if let group = object as? MTTGroupEntity {
            avatarImgv.setAvatar(group.avatar, group: true )
            nameLabel.text = group.name
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

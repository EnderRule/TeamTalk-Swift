//
//  HMContactsCell.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/24.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class HMContactsCell: HMBaseCell {

    var avatarImgv:UIImageView = UIImageView.init()
    var nameLabel:UILabel = UILabel.init()
    override func setupCustom() {
        
        avatarImgv.contentMode = .scaleAspectFit
        avatarImgv.backgroundColor = UIColor.clear
        self.contentView.addSubview(avatarImgv)
        
        nameLabel.font = fontTitle
        nameLabel.textColor = colorTitle
        nameLabel.textAlignment = .left// = .kCTLeftTextAlignment
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
            avatarImgv.setImage(str: user.avatar)
            nameLabel.text = user.name
        }else if let group = object as? MTTGroupEntity {
            avatarImgv.setImage(str: group.avatar)
            nameLabel.text = group.name
        }
    }
    

}

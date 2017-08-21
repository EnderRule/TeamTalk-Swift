//
//  HMRecentSessionCell.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class HMRecentSessionCell: HMBaseCell,HMCellConfig {

    var session:MTTSessionEntity?
    
    var headImgv:UIImageView = UIImageView.init()
    var nameLabel:UILabel = UILabel.init()
    
    var msgLabel:UILabel = UILabel.init()
    var dateLabel:UILabel = UILabel.init()
    var unreadMsgLabel:UILabel = UILabel.init()
    
    
    static let cellHeight:CGFloat = 64.0
    
    override func setupCustom(){
        headImgv.contentMode = .scaleAspectFit
        
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.textColor = colorTitle
        
        msgLabel.font = UIFont.systemFont(ofSize: 14)
        msgLabel.textColor = colorNormal
        
        
        dateLabel.font = UIFont.systemFont(ofSize: 13)
        dateLabel.textAlignment = .right
        
        unreadMsgLabel.font = UIFont.systemFont(ofSize: 14)
        unreadMsgLabel.textColor = UIColor.white
        unreadMsgLabel.backgroundColor  = UIColor.red
        unreadMsgLabel.add(corners: .allCorners, radius: CGSize.init(width: 10, height: 10))
        unreadMsgLabel.textAlignment = .center
        
        self.contentView.addSubview(headImgv)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(msgLabel)
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(unreadMsgLabel)
        
        headImgv.frame = .init(x: defaultPaddingWidth, y: defaultPaddingWidth, width: 64 - defaultPaddingWidth * 2, height: 64 - defaultPaddingWidth * 2)
        
        dateLabel.mas_makeConstraints { (maker) in
            maker?.right.equalTo()(self.contentView.mas_right)?.offset()(-defaultPaddingWidth)
            maker?.top.equalTo()(defaultPaddingWidth/2)
            maker?.width.equalTo()(120)
            maker?.height.equalTo()(20)
        }
        
        nameLabel.mas_makeConstraints { (maker ) in
            maker?.right.mas_equalTo()(self.dateLabel)
            maker?.left.mas_equalTo()(self.headImgv.mas_right)?.offset()(10)
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
            maker?.height.equalTo()(20)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let newsize = unreadMsgLabel.sizeThatFits(CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: unreadMsgLabel.height))
        unreadMsgLabel.mas_updateConstraints { (maker ) in
            maker?.width.equalTo()(max(newsize.width,20))
        }
    }
    
    func configWith(object: Any) {
        
        if let sss = object as? MTTSessionEntity {
            self.session = sss
            
            self.headImgv.setImage(str: "setting")
            
            self.nameLabel.text = sss.name.appending("  (ID:\(sss.sessionID))")
            
            let thedate = Date.init(timeIntervalSince1970: sss.timeInterval)
            self.dateLabel.text = (thedate as NSDate).transformToFuzzyDate() //"\(sss.timeInterval)"
            if sss.lastMsg.hasPrefix(DD_MESSAGE_IMAGE_PREFIX){
                self.msgLabel.text = "[圖片]"
            }else if sss.lastMsg.hasSuffix(".spx"){
                self.msgLabel.text = "[語音]"
            }else{
                self.msgLabel.text = sss.lastMsg
            }
            self.updateUnread(count: sss.unReadMsgCount)
            
            if sss.isGroupSession {
//                if let group = mttg
            }
        }
        
    }
    
    private func updateUnread(count:Int){
//        if count > 0 {
//            self.unreadMsgLabel.isHidden = false

            self.unreadMsgLabel.text = "\(count)"
//        }else {
//            self.unreadMsgLabel.isHidden = true
//        }
    }
    
}

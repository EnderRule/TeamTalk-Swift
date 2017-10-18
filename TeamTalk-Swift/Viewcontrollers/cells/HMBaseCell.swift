//
//  HMBaseCell.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit


public class HMBaseCell: UITableViewCell {

    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.setHighlighted(false , animated: false)
        // Configure the view for the selected state
    }
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupCustom()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupCustom(){
        //子类实现
    }
    
    public  func configWith(object: Any) {
    
    }
    
}

public extension UITableViewCell{
    
    func cellReloadAsTableview(){
        let tableview = self.superViewAs(aclass: UITableView.classForCoder())
        if tableview != nil{
            let indexPath = (tableview as! UITableView).indexPath(for: self)
            if indexPath != nil{
                (tableview as! UITableView).reloadRows(at: [indexPath!], with: .none)
            }
        }
    }
}

//
//  TableViewCell+Extention.swift
//  heyfriendS
//
//  Created by HZQ on 2016/11/14.
//  Copyright © 2016年 online. All rights reserved.
//

import UIKit

extension UITableViewCell {

    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
 

}

//UITableViewCellAccessoryType
public enum  MYUITableViewCellAccessoryType:Int {

    case none // don't show any accessory view
    
    case disclosureIndicator // regular chevron. doesn't track
    
    case detailDisclosureButton // info button w/ chevron. tracks
    
    case checkmark // checkmark. doesn't track
    
    @available(iOS 7.0, *)
    case detailButton // info button. tracks
    
    case switchButton //self extention type

}

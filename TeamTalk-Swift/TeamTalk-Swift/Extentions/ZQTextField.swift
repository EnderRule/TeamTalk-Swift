//
//  ZQTextField.swift
//  Linking
//
//  Created by HZQ on 2017/3/31.
//  Copyright © 2017年 online. All rights reserved.
//

import UIKit

class ZQTextField: UITextField,UITextFieldDelegate {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 5, dy: 0)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 5, dy: 0)
    }
    
}

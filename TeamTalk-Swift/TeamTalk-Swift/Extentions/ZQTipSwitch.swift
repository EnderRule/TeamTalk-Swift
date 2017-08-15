//
//  ZQTipSwitch.swift
//  Linking
//
//  Created by HZQ on 2017/2/11.
//  Copyright © 2017年 online. All rights reserved.
//

import UIKit

class ZQTipSwitch: UIView {

    
    public var valueChangeBlock:((Bool)->Void)?
    
    public var isOn:Bool{
        get{
            return switchItem.isOn
        }
    }
    
    private var labelTip:UILabel!
    private var switchItem:UISwitch!
    
    public convenience init(frame:CGRect,text:String,isOn:Bool)
    {
        self.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        labelTip = UILabel.init(frame: .init(x: 10, y: 0, width: frame.width - 20 - 50, height: frame.height))
        labelTip.textColor = colorTitle
        labelTip.text = text
        
        switchItem = UISwitch.init(frame: .init(x: frame.width - 10 - 50, y: 0, width: 50, height: 32))
        switchItem.isOn = isOn
        switchItem.addTarget(self , action: #selector(ZQTipSwitch.switchValueChange(sender:)), for: .valueChanged)
        
        self.addSubview(labelTip)
        self.addSubview(switchItem)
        
        labelTip.center.y = self.height/2
        switchItem.center.y = self.height/2
    }
    
    func switchValueChange(sender:UISwitch){
        if valueChangeBlock != nil {
            self.valueChangeBlock!(sender.isOn)
        }
    }
    
    public func setSwitch(on:Bool){
        switchItem.setOn(on, animated: true)
    }
    
    public func setTip(text:String){
        labelTip.text = text
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

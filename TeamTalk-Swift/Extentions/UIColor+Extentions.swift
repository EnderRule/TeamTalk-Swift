//
//  UIColor+Extentions.swift
//  heyfriendS
//
//  Created by HZQ on 2016/11/9.
//  Copyright © 2016年 online. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor{

    
     public convenience init(Intr:Int, g:Int, b:Int, a:CGFloat) {
         self.init(red: CGFloat(Float(Intr)/255.0), green: CGFloat(Float(g)/255.0), blue: CGFloat(Float(b)/255.0), alpha: a)
    }
    
    public convenience init(hexString:String){
        self.init(hexString: hexString, alpha: 1)
    }
    
    //the hex string must be prefix #,0X or 0x ,6~8 length.
    public convenience init(hexString:String, alpha:Float) {
        
        var cString:NSString = hexString as NSString
        // String should be 6 or 8 characters
        if (cString.length < 6){
            self.init(Intr:0, g:0, b:0, a:1)
        }else{
            //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
            if cString.hasPrefix("0X") || cString.hasPrefix("0x"){
                cString = cString.substring(from: 2) as NSString
            }
            //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
            if cString.hasPrefix("#"){
                cString = cString.substring(from: 1) as NSString
            }
            
            if cString.length != 6{
                self.init(Intr:0, g:0, b:0, a:1)
            }else{
                let rstring:NSString = cString.substring(to: 2) as NSString
                let gstring:NSString = (cString.substring(from: 2) as NSString).substring(to: 2) as NSString
                let bstring:NSString = (cString.substring(from: 4) as NSString).substring(to: 2) as NSString
                
                var r:UInt32 = 0,g:UInt32 = 0,b:UInt32 = 0;
                
                Scanner(string:rstring as String).scanHexInt32(&r)
                Scanner(string:gstring as String).scanHexInt32(&g)
                Scanner(string:bstring as String).scanHexInt32(&b)
            
                self.init(Intr:Int(r),g:Int(g),b:Int(b),a:CGFloat(alpha))
            }
        }
    }
    
//    public func randomColor()->UIColor{
//        let hue:CGFloat = (CGFloat(arc4random()%256) / 256.0)
//        let saturation:CGFloat = (CGFloat(arc4random()%128) / 256.0) + 0.5
//        let brightness:CGFloat = (CGFloat(arc4random()%128) / 256.0) + 0.5
//        return UIColor.init(hue: hue, saturation: saturation, lightness: brightness)
//    }
}

 //MARK: 顏色常量
let colorClear              = UIColor.clear
let colorTabBarTint         = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
let colorTabBarBack         = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
let colorNaviBarBack        = UIColor.white
let colorNaviBarTint        = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
let colorAlphaWhiteCover    = UIColor.init(Intr: 234, g: 234, b: 234, a: 0.7)
let colorTabBarLightTint    = UIColor.init(Intr: 141, g: 208, b: 243, a: 1)

let colorPrimary        = UIColor.init(hexString: "#fafafa")
let colorPrimaryDark    = UIColor.init(hexString: "#ffffff")

let colorNormal         = UIColor.init(hexString: "#646464")
let colorMinor          = UIColor.init(hexString: "#a6a5a5")
let colorTitle          = UIColor.init(hexString: "#4b4b4b")
let gainsboro           = UIColor.init(hexString: "#dcdcdc")
let colorSeperateLine   = UIColor.init(hexString: "#eaeaea")
let colorMainBg         = UIColor.init(hexString: "#f5f4f3")

let colorSysTint        = UIColor.init(Intr: 28, g: 121, b: 251, a: 1)

let colorMan            = UIColor.init(hexString: "#AEC7F2")
let colorWoman          = UIColor.init(hexString: "#f5b7c6")
let colorOfficial       = UIColor.init(hexString: "#ffb300")

let colorLevel          = UIColor.init(Intr: 231, g: 214, b: 201, a: 1)
let colorAdLabel        = UIColor.init(Intr: 150, g: 205, b: 227, a: 1)

let colorDefaultOrange  = UIColor.init(hexString: "#ffa53f")
let colorDefaultGreen   = UIColor.init(hexString: "#26AA24")
let colorDefaultRed     = UIColor.init(Intr: 201, g: 97, b: 97, a: 1)
let colorDefaultBlue    = UIColor.init(Intr: 105, g: 193, b: 232, a: 1)

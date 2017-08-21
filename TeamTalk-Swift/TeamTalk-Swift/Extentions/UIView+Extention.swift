//
//  UIView+Extention.swift
//  heyfriendS
//
//  Created by HZQ on 2016/11/9.
//  Copyright © 2016年 online. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    var top:CGFloat{
        set{
            self.frame.origin.y = newValue
        }
        get{
            return self.frame.origin.y
        }
    }
    var left:CGFloat{
        set{
            self.frame.origin.x = newValue
        }
        get{
            return self.frame.origin.x
        }
    }
    var bottom:CGFloat{
        set{
            self.frame.origin.y = newValue - self.frame.size.height
        }
        get{
            return self.frame.origin.y + self.frame.size.height
        }
    }
    var right:CGFloat{
        set{
            self.frame.origin.x = newValue - self.frame.size.width
        }
        get{
            return self.frame.origin.x + self.frame.size.width
        }
    }
    var centerX:CGFloat{
        set{
            self.center = CGPoint.init(x: newValue, y: self.center.y)
        }
        get{
            return self.center.x
        }
    }
    var centerY:CGFloat{
        set{
            self.center = CGPoint.init(x: self.center.x, y: newValue)
        }
        get{
            return self.center.y
        }
    }
    var width:CGFloat{
        set{
            self.frame.size.width = newValue
        }
        get{
            return self.frame.size.width
        }
    }
    var height:CGFloat{
        set{
            self.frame.size.height = newValue
        }
        get{
            return self.frame.size.height
        }
    }
    var origin:CGPoint{
        set{
            self.frame.origin = newValue
        }
        get{
            return self.frame.origin
        }
    }
    var size:CGSize{
        set{
            self.frame.size = newValue
        }
        get{
            return self.frame.size
        }
    }
    
    
    
    
    func addCommonTap(target:Any,sel:Selector){
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: target, action: sel)
        self.addGestureRecognizer(tap)
    }
    
    func checkScrollToTop(){
        if self.alpha == 0 || self.isHidden == true {
            return
        }else if self.isKind(of: UIScrollView.classForCoder()){
            let scrollview:UIScrollView = self as! UIScrollView
            scrollview.scrollRectToVisible(.init(x: 0, y: 0, width: 2, height: 2), animated: true)
        }else{
            for subview in self.subviews{
                subview.checkScrollToTop()
            }
        }
    }
    
    func checkScrollToBottom(){
        if self.alpha == 0 || self.isHidden == true {
            return
        }else if self.isKind(of: UIScrollView.classForCoder()){
            let scrollview:UIScrollView = self as! UIScrollView
            scrollview.scrollRectToVisible(.init(x: 0, y: scrollview.contentSize.height - 3, width: 2, height: 2), animated: true)
        }else{
            for subview in self.subviews{
                subview.checkScrollToBottom()
            }
        }
    }
    
    
    func viewController()->UIViewController?{
        var next = self.next
        while next != nil {
            if next!.isKind(of: UIViewController.classForCoder()){
                return next! as? UIViewController
            }
            next = next!.next
        }
        return nil
    }
    
    func superViewAs(aclass:AnyClass)->Any?{
        if self.superview != nil{
            if self.superview!.classForCoder == aclass{
                return self.superview!
            }else{
                return self.superview!.superViewAs(aclass:aclass)
            }
        }else{
            return nil
        }
    }
    
//    func genarateImage()->UIImage? {
//        let size = self.bounds.size
//        
//        UIGraphicsBeginImageContextWithOptions(size , false , UIScreen.main.scale)
//        self.layer.render(in: UIGraphicsGetCurrentContext()!)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        
//        UIGraphicsEndImageContext()
//        
//        return image
//    }
    
//    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.next?.touchesBegan(touches, with: event)
//        self.superview?.touchesBegan(touches, with: event)
//    }
//    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        debugPrint("extention touch moved ")
//        self.next?.touchesMoved(touches, with: event)
//        self.superview?.touchesMoved(touches, with: event)
//    }
//    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.next?.touchesEnded(touches, with: event)
//        self.superview?.touchesEnded(touches, with: event)
//    }
//    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.next?.touchesCancelled(touches, with: event)
//        self.superview?.touchesCancelled(touches, with: event)
//    }
}


public enum ZQSeperateLinePosition:Int  {
    case top = 0
    case left = 1
    case bottom = 2
    case right = 3
    case centerHorizontal = 4
    case centerVertical = 5
    
    case none = 6
}

class ZQLineViewStyle: NSObject {
    var position:ZQSeperateLinePosition = .top
    var width:CGFloat = 1.0
    var color:UIColor = UIColor.lightGray
    var inset:CGFloat = 0.0
    var roundCornor:Bool = false //末端圆角
    var scaleRate:CGFloat = 1.0  //相对于主view缩小的比例  0~1之间
}

//MARK:分隔線
extension UIView{
    func addLine(style:ZQLineViewStyle){
        if style.position.rawValue >= 0 && style.position.rawValue <= 5{
            self.addLine(position: style.position, lineWidth: style.width, color: style.color, lineInset: style.inset, scaleRate: style.scaleRate, roundCorner: style.roundCornor)
        }
    }
    
    //positionRawValue: 0=top  1=left  2=bottom  3=right  4=centerHorizontal  5=cengerVertical
    func addLine(positionRawValue:Int,lineWidth:CGFloat,color:UIColor,lineInset:CGFloat,scaleRate:CGFloat,roundCorner:Bool){
        if positionRawValue >= 0 && positionRawValue <= 5 {
            self.addLine(position: ZQSeperateLinePosition.init(rawValue: positionRawValue)!, lineWidth: lineWidth, color: color, lineInset: lineInset, scaleRate: scaleRate, roundCorner: roundCorner)
        }
    }
    
    func removeLine(position:ZQSeperateLinePosition){
        let lineTag = 7137130 + position.rawValue
        self.viewWithTag(lineTag)?.removeFromSuperview()
    }
    
    func addLine(position:ZQSeperateLinePosition,lineWidth:CGFloat,color:UIColor,lineInset:CGFloat,scaleRate:CGFloat,roundCorner:Bool){
        if position == .none{
            return
        }
        
        var xx:CGFloat = 0
        var yy:CGFloat = 0
        var ww:CGFloat = 0
        var hh:CGFloat = 0
        
        var tempScaleRate:CGFloat = scaleRate
        
        if tempScaleRate > 1 {
            tempScaleRate = 1
        }
        
        switch position {
        case .top:
            xx = self.width*(1 - tempScaleRate)/2
            yy = lineInset
            
            ww = self.width * (tempScaleRate > 1 ? 1:tempScaleRate)
            hh = lineWidth
            
            break
        case .left:
            yy = self.height * (1 - tempScaleRate)/2
            xx = lineInset
            
            hh = self.height * (tempScaleRate > 1 ? 1:tempScaleRate)
            ww = lineWidth
            break
        case .bottom:
            
            xx = self.width*(1 - tempScaleRate)/2
            yy = self.height - lineInset - lineWidth
            
            ww = self.width * (tempScaleRate > 1 ? 1:tempScaleRate)
            hh = lineWidth
            break
        case .right:
            yy = self.height * (1 - tempScaleRate)/2
            xx = self.width - lineInset - lineWidth
            
            hh = self.height * (tempScaleRate > 1 ? 1:tempScaleRate)
            ww = lineWidth
            break
        case .centerVertical:
            yy = self.height * (1 - tempScaleRate)/2
            xx = self.width/2 - lineWidth/2
            
            hh = self.height * (tempScaleRate > 1 ? 1:tempScaleRate)
            ww = lineWidth
            break
        case .centerHorizontal:
            xx = self.width*(1 - tempScaleRate)/2
            yy = self.height/2 - lineWidth/2
             
            ww = self.width * (tempScaleRate > 1 ? 1:tempScaleRate)
            hh = lineWidth
            break
        default:
            break
        }
        
        let lineTag = 7137130 + position.rawValue
        self.viewWithTag(lineTag)?.removeFromSuperview()
        
        let lineView:UIView = UIView.init(frame: .init(x: xx, y: yy, width: ww, height: hh))
        lineView.backgroundColor = color
        lineView.tag = lineTag
        if roundCorner {
            lineView.layer.cornerRadius = lineWidth
        }
        self.addSubview(lineView)
    }

}

extension UIView{
    //set frame before add corners
    func add(corners:UIRectCorner,radius:CGSize){
        
        let path:UIBezierPath = UIBezierPath.init(roundedRect: .init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height),
                                                  byRoundingCorners: corners,
                                                  cornerRadii: radius)
        
        let shapelayer:CAShapeLayer = CAShapeLayer.init()
        shapelayer.frame = self.bounds
        shapelayer.path = path.cgPath
        
        self.layer.mask = shapelayer
    }
    
    //截图
    func viewShot()->UIImage? {
        UIGraphicsBeginImageContext(self.bounds.size)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
    
    
}



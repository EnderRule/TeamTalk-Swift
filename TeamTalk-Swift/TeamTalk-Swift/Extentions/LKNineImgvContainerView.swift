//
//  LKNineImgvContainerView.swift
//  Linking
//
//  Created by HZQ on 2017/5/15.
//  Copyright © 2017年 online. All rights reserved.
//

import UIKit

class LKNineImgvContainerView: UIView {

    var imagePaths:[[String:Any]]{
        set{
            self.innerImagePaths = newValue
            self.reloadImages()
        }
        get{
            return self.innerImagePaths
        }
    }
    var maxPerRow:Int = 3
    var maxRows:Int = 3
    var tapAtIndex:((Int)->Void)?
    
    var innerImagePaths:[[String:Any]] = []
    private var imgvs:[UIImageView] = []
    
    func setupSubviews(){
        
        for subview in  self.subviews{
            subview.removeFromSuperview()
        }
        let count:Int = maxPerRow * maxRows
        for index in 0..<count {
            let imgv = UIImageView.init()
            imgv.contentMode = .scaleAspectFit
            imgv.tag = index
            imgv.backgroundColor = UIColor.red
            self.addSubview(imgv)
            
            imgv.isHidden = true
        }
    }
    
    func reloadImages(){
        let count:Int = maxPerRow * maxRows

        for index in 0..<count {
            if index < innerImagePaths.count{
                (self.viewWithTag(index) as? UIImageView)?.image = nil
                
                let dic = innerImagePaths[index]
                let url = dic["thumb_url"] as? String ?? dic["url"] as? String
                (self.viewWithTag(index) as? UIImageView)?.setImage(str: url ?? "placeHolderImage", placeHolder: #imageLiteral(resourceName: "placeHolderImage"))
                (self.viewWithTag(index) as? UIImageView)?.isHidden = false
            }else{
                self.viewWithTag(index)?.isHidden = true
            }
        }
    }
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        self.reloadImages()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let count:Int = maxPerRow * maxRows
        
        for index in 0..<count{
            let xValue:Int = index/maxPerRow
            let yValue:Int = index%maxPerRow
            let itemWith = (self.width - (CGFloat( maxPerRow ) + 1.0) * defaultPaddingWidth)/CGFloat( maxPerRow)

            (self.viewWithTag(index) as? UIImageView)?.frame = .init(x: defaultPaddingWidth + itemWith * CGFloat(yValue), y: defaultPaddingWidth + itemWith * CGFloat(xValue), width: itemWith, height: itemWith)
            
        }
    }
    

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.tapAtIndex != nil{
            let touchPoint = (touches.first?.location(in: self))
            if touchPoint != nil{
                for index in 0..<self.maxRows * self.maxPerRow{
                    if self.viewWithTag(index) != nil &&  self.viewWithTag(index)!.isHidden && self.viewWithTag(index)!.frame.contains(touchPoint!){
                        self.tapAtIndex!(self.viewWithTag(index)!.tag)
                    }
                }
            }
        }
        
        self.next?.touchesEnded(touches, with: event)
    }
    
}

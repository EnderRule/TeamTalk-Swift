//
//  UIImageView+Extention.swift
//  heyfriendS
//
//  Created by HZQ on 2017/1/25.
//  Copyright © 2017年 online. All rights reserved.
//

import UIKit
import ObjectiveC

//        /var/mobile/Containers/Data/Application/0FBE1903-8658-4462-BAA0-C877918D0757/Documents/InPostingImages/new_1497867259_0.jpg
//測試時發現、Application/之後的32位文件夾ID会動態改變，這裡要把它替換掉，才能正常加載圖片

extension UIImageView{
    
    //str:local resource name ,or imageFilePath at sandbox,or imageURL.
    open func setImage(str:String){
        self.setImage(str: str , placeHolder: nil, cornerRadius: 0)
    }
    
    open func setImage(str:String,placeHolder:UIImage?){
        self.setImage(str: str , placeHolder: placeHolder, cornerRadius: 0)
    }
    
    open func setImage(str:String,placeHolder:UIImage?,cornerRadius:CGFloat?){
        
        let range:NSRange = (str as NSString).range(of: "/var/mobile/Containers/Data/Application/")
        if range.length > 0{
            
            var newfilePath = str
            if !FileManager.default.fileExists(atPath: newfilePath){
                let newPart:String  = (str as NSString).substring(from: range.location+range.length+36)
                
                newfilePath = NSHomeDirectory().appending(newPart)
            }
            
            if FileManager.default.fileExists(atPath: newfilePath){
                
                if newfilePath.hasSuffix(".gif"){
                    do {
                        let data = try NSData.init(contentsOfFile: newfilePath) as Data  // try Data.init(contentsOf: URL.init(string: newfilePath)!)
                        let contentType = NSData.sd_contentType(forImageData: data)
                        
                        if contentType == "image/gif"{
                            let image = UIImage.sd_animatedGIF(with: data)
                            self.image = image
                            return
                        }
                    }catch{
//                        debugPrint("read gif data error:\(error.localizedDescription) \n\n\(newfilePath)")
                    }
                }
                
                let image = UIImage.init(contentsOfFile: newfilePath)
                
//                debugPrint("non gif \(newfilePath) imagescount \(image?.images?.count ?? 0)")
                
                self.image = image
                
                return
            }
        }
        
        if str.lowercased().hasPrefix("http") {

            self.sd_setImage(with: URL.init(string: str), placeholderImage: placeHolder,corner: cornerRadius ?? 0.0)
        }else if str.lowercased().hasPrefix("file://") || str.lowercased().hasPrefix("/"){
            let image = UIImage.init(contentsOfFile: str)
            
            if cornerRadius ?? 0.0 > 0{
                self.image = image?.cornerImage(radius: cornerRadius!, sizetoFit: self.frame.size)
            }else{
                self.image = image
            }
        }else {
            if str.length > 0{
                let image = UIImage.init(named: str)
                if image == nil {
                    if cornerRadius ?? 0.0 > 0 && placeHolder != nil{
                        self.image = placeHolder?.cornerImage(radius: cornerRadius!, sizetoFit: self.frame.size)
                    }else{
                        self.image = placeHolder
                    }
                }else{
                    if cornerRadius ?? 0.0 > 0{
                        self.image = image?.cornerImage(radius: cornerRadius!, sizetoFit: self.frame.size)
                    }else{
                        self.image = image
                    }
                }
            }else{
                if cornerRadius ?? 0.0 > 0 && placeHolder != nil {
                    self.image = placeHolder?.cornerImage(radius: cornerRadius!, sizetoFit: self.frame.size)
                }else{
                    self.image = placeHolder
                }
            }
        }
    }
    
    //MARK:添加停權標誌
    open func addForbbidenTag(){
        if self.viewWithTag(10110) != nil {
            self.viewWithTag(10110)!.isHidden = false
        }else{
            let coverView = UIView.init(frame: .init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
            coverView.backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.35)
            coverView.tag = 10110
            
            let width:CGFloat = self.frame.size.width * 0.4
            let imgv = UIImageView.init(frame: .init(x:0, y:0, width: width, height: width))
            imgv.image = #imageLiteral(resourceName: "forbidden")
            imgv.center.x = coverView.width/2
            imgv.center.y = coverView.height/2
            
            coverView.addSubview(imgv)
            coverView.isHidden = false
            
            self.addSubview(coverView)
        }
    }
    open func removeForbbidenTag() {
        self.viewWithTag(10110)?.isHidden = true
    }
    
    //MARK:添加GIF標誌
    open func addGifTag(){
        
        if self.image != nil && self.image!.images != nil {
            let width:CGFloat = 32
            let height:CGFloat = width/2
            if self.viewWithTag(10111) != nil {
                self.viewWithTag(10111)!.isHidden = false
            }else{
                let imgv = UIImageView.init(frame: .init(x:0, y:0, width: width, height: height))
                imgv.tag = 10111
                imgv.image = #imageLiteral(resourceName: "ic_gif")
                
                imgv.isHidden = false
                self.addSubview(imgv)
            }
            self.viewWithTag(10111)?.center  = CGPoint.init(x: self.width - width/2, y: self.height - height/2) //右下角
        }else{
            self.removeGifTag()
        }
    }
    open func removeGifTag() {
        self.viewWithTag(10111)?.isHidden = true
    }
    
    
    
    //MARK:添加點擊事件
    open func addTapAction(action:Selector,target:Any){
        let tap = UITapGestureRecognizer.init(target: target , action: action)
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
    
}

/*  CGRect bounds = self.bounds;
    [[UIColor whiteColor] set];
    UIRectFill(bounds);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:10] addClip];
    [self.image drawInRect:bounds];
 */
    


//classZQImageView: UIImageView {
//    open var tapBlock:(()->Void)?
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.next?.touchesBegan(touches, with: event)
//    }
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if self.tapBlock != nil {
//            self.tapBlock!()
//        }
//        self.next?.touchesEnded(touches, with: event)
//    }
//}


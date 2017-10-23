//
//  UITextView+Extention.swift
//  Linking
//
//  Created by HZQ on 2017/3/22.
//  Copyright © 2017年 online. All rights reserved.
//

import UIKit

extension UITextView {

    func setVerticallyCenteredText(text:String){
        self.text = text
        let newSize:CGSize = self.sizeThatFits(.init(width: self.fr_width, height: CGFloat.greatestFiniteMagnitude))
        let topInset:CGFloat = (self.fr_height - newSize.height)/2.0
        
        if topInset > 0{
            self.contentInset = .init(top: topInset, left: self.contentInset.left, bottom: topInset, right: self.contentInset.right)
        }
    }
    
    func setVerticallyCenteredAttributeText(attText:NSAttributedString){
        self.attributedText = attText
        let newSize:CGSize = self.sizeThatFits(.init(width: self.fr_width, height: CGFloat.greatestFiniteMagnitude))
        let topInset:CGFloat = (self.fr_height - newSize.height)/2.0
        
        if topInset > 0{
            self.contentInset = .init(top: topInset, left: self.contentInset.left, bottom: topInset, right: self.contentInset.right)
        }
    }
    
}

extension UILabel{
    public func addDefaultShadow(){
        if self.text != nil && self.text!.length > 0{
            let attStr = NSAttributedString.init(string: self.text!, attributes: [NSFontAttributeName:self.font,NSShadowAttributeName:defaultShadow()])
            self.attributedText = attStr
        }
    } 
}

class ZQPlaceHolderTextView: UITextView {
    
    var placeHolder:String{
        get{
            return self.privatePlaceHolder
        }
        set{
            self.setNeedsDisplay()
            self.privatePlaceHolder = newValue
            
        }
    }
    private var privatePlaceHolder:String = ""
    
    public convenience init(placeHolder:String){
        self.init()
        
        self.privatePlaceHolder = placeHolder
        NotificationCenter.default.addObserver(self , selector: #selector(textviewTextDidChanged), name: Notification.Name.UITextViewTextDidChange, object: self)
        NotificationCenter.default.addObserver(self , selector: #selector(textviewDidEndEditing), name: Notification.Name.UITextViewTextDidEndEditing, object: self)

        self.setNeedsDisplay()
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if self.text.length <= 0 && self.privatePlaceHolder.length > 0 {
            let placeHolderRect = CGRect.init(x: defaultPaddingWidth, y: defaultPaddingWidth, width: rect.width, height: rect.height)
            let paragraphStyle = NSMutableParagraphStyle.init()
            paragraphStyle.lineBreakMode = .byTruncatingTail
            paragraphStyle.alignment = self.textAlignment
            (self.privatePlaceHolder as NSString).draw(in: placeHolderRect, withAttributes: [NSFontAttributeName:self.font ?? UIFont.systemFont(ofSize: 14.0),NSForegroundColorAttributeName:UIColor.gray,NSParagraphStyleAttributeName:paragraphStyle])
        }
    }
    
    func textviewTextDidChanged(){
        self.setNeedsDisplay()
    }
    func textviewDidEndEditing(){
        self.setNeedsDisplay()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        self.setNeedsDisplay()
    }
    
    deinit {
        debugPrint("ZQPlaceHolderTextView deinit: remove observer")
        
        NotificationCenter.default.removeObserver(self)
    }
}

extension UITextView{
    
    class func contentSizeWith(attributeString:NSAttributedString,staticWith:CGFloat,maxHeight:CGFloat?)->CGSize{
        if attributeString.length == 0{
            return CGSize.init(width: staticWith, height: 2)
        }
        let tempText:UITextView = UITextView.init()
        tempText.attributedText = attributeString
        return tempText.sizeThatFits(CGSize.init(width: staticWith, height: maxHeight != nil ? maxHeight! : CGFloat.greatestFiniteMagnitude))
    }
    
    func attributeContentHeight()->CGFloat{
        return UITextView.contentSizeWith(attributeString: self.attributedText, staticWith: self.fr_width, maxHeight: nil).height
    }
}

//
//  UIScrollView+Extention.swift
//  Linking
//
//  Created by HZQ on 2017/2/9.
//  Copyright © 2017年 online. All rights reserved.
//

import UIKit
import Foundation


class UIScrollViewExt: UIScrollView{

    open var touchAtPointBlock:((CGPoint)->Void)?
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesBegan(touches, with: event)
    }
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        let touch = touches.first
        let locationPoint = touch?.location(in: self)
        
        if self.touchAtPointBlock != nil {
            self.touchAtPointBlock!(locationPoint!)
        }
        
        self.next?.touchesEnded(touches, with: event)
    }
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        self.next?.touchesMoved(touches, with: event)
    }
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {

        self.next?.touchesCancelled(touches, with: event)
    }

    
    
}

extension UIScrollView{
    
    open func setScrollable(contentSize:CGSize){
        self.isScrollEnabled = true
        self.isUserInteractionEnabled = true
        
        if contentSize.height < self.height{
            self.contentSize = CGSize.init(width: contentSize.width, height: self.height+1)
        }else{
            self.contentSize = contentSize
        }
    }
    
    public func createInfoItemView(title:String,detail:String,itemFrame:CGRect)->UIView{
        let itemview = UIView.init(frame: .init(x: itemFrame.origin.x, y: itemFrame.origin.y, width: itemFrame.size.width, height: 100))
        itemview.backgroundColor = UIColor.white
        let lineview = UIView.init(frame: .init(x: 0, y: 0, width: itemview.width, height: 10))
        lineview.backgroundColor = colorPrimary
        
        let titleLb = UILabel.init(frame: .init(x: 20, y: lineview.bottom, width: itemview.width - 40, height: 30))
        titleLb.backgroundColor = UIColor.clear
        titleLb.text = title
        titleLb.textColor = colorTitle
        titleLb.font = mainTipTitleFont
        
        let detailTV = UITextView.init(frame: .init(x: 15, y: titleLb.bottom, width: itemview.width - 30, height: 30))
        detailTV.isEditable = false
        detailTV.showsVerticalScrollIndicator = false
        detailTV.showsHorizontalScrollIndicator = false
        detailTV.font = UIFont.systemFont(ofSize: 15)
        detailTV.textColor = colorNormal
        detailTV.text = detail
        detailTV.backgroundColor  = UIColor.clear
        
        let style:NSMutableParagraphStyle = NSMutableParagraphStyle.init()
        style.alignment = .left
        style.minimumLineHeight = 20
        style.maximumLineHeight = 20
        style.lineSpacing = 5
        style.paragraphSpacing = 5
        style.lineBreakMode = .byWordWrapping
        style.lineHeightMultiple = 1.5
        
        let attrtbutes:[String:Any] = [NSFontAttributeName:detailTV.font!,NSParagraphStyleAttributeName:style]
        let attriStr = NSAttributedString.init(string: detail, attributes: attrtbutes)
        detailTV.attributedText = attriStr
        
        let newSize = detailTV.sizeThatFits(CGSize.init(width: detailTV.width, height: CGFloat(MAXFLOAT)))
        detailTV.frame.size.height = newSize.height + 5
        
        itemview.frame.size.height = detailTV.bottom
        itemview.addSubview(lineview)
        itemview.addSubview(titleLb)
        itemview.addSubview(detailTV)
        
        return itemview
    }
    
    public func createInfoItemView(title:NSAttributedString,subView:UIView,itemFrame:CGRect)->UIView{
        let itemview = UIView.init(frame: .init(x: itemFrame.origin.x, y: itemFrame.origin.y, width: itemFrame.size.width, height: 100))
        itemview.backgroundColor = UIColor.white
        
        let titleLb = UILabel.init(frame: .init(x: 20, y: 15, width: itemview.width - 40, height: 35))
        titleLb.backgroundColor = UIColor.clear
        titleLb.attributedText = title
        titleLb.textColor = colorTitle
        titleLb.font = mainTipTitleFont
        
        subView.top = titleLb.bottom
        
        itemview.frame.size.height = subView.bottom + 10
        
        itemview.addSubview(titleLb)
        itemview.addSubview(subView)
        itemview.addLine(position: .top, lineWidth: 15, color: colorPrimary, lineInset: 0.0, scaleRate: 1.0, roundCorner: false)

        return itemview
    }
//    防止scrollView手势覆盖侧滑手势
//    [scrollView.panGestureRecognizerrequireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
}

//MJRefresh easy handling
extension UIScrollView {
    
    func addHeader(_ callback:(()->Void)){
        
    }
 
    func headerEndRefreshing(){

        self.mj_header.endRefreshingCompletionBlock()
        
    }
    
}






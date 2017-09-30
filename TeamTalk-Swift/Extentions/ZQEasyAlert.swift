//
//  ZQEasyAlert.swift
//  heyfriendS
//
//  Created by HZQ on 2016/12/28.
//  Copyright © 2016年 online. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
extension UIAlertController{
    
    public class func alert(sender:UIViewController, title:String?,message:String?,buttons:[String],clickHandler:@escaping ((String,Int)->Void)){
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        
        for buttontitle in buttons {
            let index = buttons.index(of: buttontitle)
            
            let action = UIAlertAction.init(title: buttontitle, style: .default, handler: {action in
                clickHandler(buttontitle,index!)
            })
            
            alert.addAction(action)
        }
    
        sender.present(alert, animated: true , completion: nil)
    }
    
    public class func defaultAlert(_ title:String?,message:String?,buttons:[String],clickHandler:@escaping ((String,Int)->Void)){
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        
        for buttontitle in buttons {
            let index = buttons.index(of: buttontitle)
            
            let action = UIAlertAction.init(title: buttontitle, style: .default, handler: {action in
                clickHandler(buttontitle,index!)
            })
            
            alert.addAction(action)
        }
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true , completion: nil)
    }
    
    public class func alertActionSheet(sender:UIViewController,sourceView:UIView, title:String?,message:String?,buttons:[String],clickHandler:@escaping ((String,Int)->Void)){

        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .actionSheet)
        for buttontitle in buttons {
            let index = buttons.index(of: buttontitle)
            
            let action = UIAlertAction.init(title: buttontitle, style: .default, handler: {action in
                clickHandler(buttontitle,index!)
            })
            
            alert.addAction(action)
        }
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceView.bounds
        } 
        sender.present(alert, animated: true , completion: nil)
    }
}

@available(iOS 8.0, *)
class ZQCustomViewAlert: UIAlertController {
    
    private var customView:UIView = UIView.init()
    
    
    public func alert(_ customView:UIView){

        self.customView  = customView
    
        UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: true , completion: nil)
    }
    
    
    override func loadView() {
        
        self.view = customView
        
    }
}

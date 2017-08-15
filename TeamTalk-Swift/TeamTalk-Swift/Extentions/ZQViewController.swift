//
//  ZQViewController.swift
//  Linking
//
//  Created by HZQ on 2017/3/9.
//  Copyright © 2017年 online. All rights reserved.
//

import UIKit

class ZQViewController : UIViewController,UIGestureRecognizerDelegate {
    
    private var hasAddKeyboardObserver:Bool = false
    
    var userClearBar:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setEdgeNone()
        self.addbackButton()
        self.view.backgroundColor = colorMainBg

        self.addClearBarFixView()
        
        //全屏右滑返回
//        let pan = UIPanGestureRecognizer(target: target, action:(Selector(("handleNavigationTransition:"))))
//        pan.delegate = self
//        self.view.addGestureRecognizer(pan)
//        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (userClearBar) {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        if self.parent == self.navigationController{
            
            self.setNaviBarClear(clear: userClearBar)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
//        if (self.navigationController?.viewControllers.count)! > 1{
//            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
//        }else{
//            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        self.setNaviBarClear(clear: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardObserver()
//        SVProgressHUD.dismiss()
        
        let topVC = self.navigationController?.topViewController
        if (topVC as? ZQViewController) != nil{
            if (topVC as! ZQViewController).userClearBar{
                self.setNaviBarClear(clear: true)
            }else{
                self.setNaviBarClear(clear: false)
            }
        }else{
            self.setNaviBarClear(clear: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
//        SDImageCache.shared().clearMemory()
    }
    
    func addKeyboardObserver(){
        if !hasAddKeyboardObserver{
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(sender:)), name: Notification.Name.UIKeyboardDidShow, object: nil)
            hasAddKeyboardObserver = true
        }
    }
    func removeKeyboardObserver(){
        if hasAddKeyboardObserver{
            NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardDidShow, object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
            hasAddKeyboardObserver = false
        }
    }
    
    func keyboardWillHide(sender:Notification){
    }
    func keyboardDidShow(sender:Notification){
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
     //全屏右滑返回 return true
        if gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer{
            return true
        }
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self )
    }
}

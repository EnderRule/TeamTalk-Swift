//
//  UIViewController+Extention.swift
//  heyfriendS
//
//  Created by HZQ on 2016/10/28.
//  Copyright © 2016年 online. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    
    open func setEdgeNone() -> Void {
        self.edgesForExtendedLayout = UIRectEdge(rawValue: UInt(0))
    }
    
    open func addbackButton() -> Void{

        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "bar_button_back2").withRenderingMode(.alwaysTemplate),
                                                                     style: UIBarButtonItemStyle.plain,
                                                                     target: self,
                                                                     action:#selector(UIViewController.touchBackButton))
        self.navigationItem.leftBarButtonItem?.tintColor = colorNormal
    }
    func touchBackButton() -> Void {
        if self.navigationController != nil{
//            _ = self.navigationController?.popViewController(animated: true)

            if self.navigationController?.childViewControllers.first != nil
                && self.navigationController?.childViewControllers.first!.classForCoder == self.classForCoder {
                self.navigationController?.dismiss(animated: true, completion: nil)
                
            }else{
                _ = self.navigationController?.popViewController(animated: true)
            }
        }else {
            self.dismiss(animated: true , completion: nil)
        }
        
        //修复navibar 异常消失问题。
        if self.rootNaviCtrl().childViewControllers.count <= 1{
            self.rootNaviCtrl().setNavigationBarHidden(true, animated: false)
        }else{
            for subvc in  self.rootNaviCtrl().childViewControllers {
                if subvc.navigationController == self.rootNaviCtrl(){
                    self.rootNaviCtrl().setNavigationBarHidden(false, animated: false)
                }
            }
        }
    }
    
    open func rootNaviPresentVC(targetVC:UIViewController, animated:Bool,completion:@escaping (()->Void)) ->Void{
        self.rootNaviCtrl().setNavigationBarHidden(false, animated: false)
        self.rootNaviCtrl().present(targetVC, animated: true, completion: completion)
    }
    
    
    open func pushLoginVC(){
//
//        if !(self.rootNaviCtrl().topVC().isKind(of: UserLoginViewController.classForCoder())) {
//            
//            let loginVC = UserLoginViewController.init()
//            loginVC.hidesBottomBarWhenPushed = true
//            
//            self.rootNaviCtrl().setViewControllers([loginVC], animated: true)
//            debugPrint("rootNavi last VC viewTag:",self.rootNaviCtrl().childViewControllers.last?.view.tag ?? "no tag")
//        }
    }
    
    func rootNaviCtrl()->UINavigationController{
        return (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController) ?? UINavigationController.init()
    }
    
    
    func forceLogout() {
        self.pushLoginVC()
    }
    
    func topVC()->UIViewController {
        let rootVC = UIApplication.shared.keyWindow?.rootViewController ?? self
        var resultVC:UIViewController = self.get_topVCFor(vc: rootVC)
        while (resultVC.presentedViewController != nil && resultVC.presentingViewController != nil) {
            resultVC = self.get_topVCFor(vc: resultVC.presentedViewController!)
        }
        return resultVC;
    }
    
    private func get_topVCFor(vc:UIViewController)->UIViewController {
        
//        debugPrint("\n\n \(self) \nget topvc for\n\(vc)")
        
        if vc.isKind(of: UINavigationController.classForCoder()) {
            if let lastVC = (vc as! UINavigationController).viewControllers.last{
                return self.get_topVCFor(vc:lastVC)
            }else{
                return vc
            }
        } else if vc.isKind(of: UITabBarController.classForCoder()) {
            if let selectedVC = (vc as! UITabBarController).selectedViewController {
                return self.get_topVCFor(vc:selectedVC)
            }else{
                return vc
            }
        } else {
            return vc;
        }
    }
    
    func setNaviBarClear(clear:Bool){
        if clear{
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.setBackgroundImage(UIImage.imageWith(color: UIColor.clear, size: .init(width: 1, height: 1)), for: .default)
            self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        }else{
            self.navigationController?.navigationBar.shadowImage = nil
            self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            self.navigationController?.navigationBar.backgroundColor = colorNaviBarBack
        }
    }
}


//MARK:當設置透明導航欄、過渡時會有黑條，添加一個背景view
extension UIViewController{
    func addClearBarFixView(){
        let fixView = UIView.init(frame: .init(x: 0, y: -64, width: self.view.width, height: 64))
        fixView.backgroundColor = self.view.backgroundColor
        fixView.tag = 814814
        self.view.addSubview(fixView)
    }
    
    func removeClearBarFixView(){
        self.view.viewWithTag(814814)?.removeFromSuperview()
    }
}


extension UINavigationController{

    func setNeedsNavigationBarBackground(alpha:CGFloat){
        debugPrint("log setNeedsNavigationBarBackground 1 \(self.navigationBar.subviews)")
        if self.navigationBar.subviews.count > 0{
            debugPrint("log setNeedsNavigationBarBackground 2")

            let barBackgroundView:UIView = self.navigationBar.subviews[0]
            if self.navigationBar.isTranslucent{
                debugPrint("log setNeedsNavigationBarBackground 3")

                let backgroundImageView = barBackgroundView .subviews[0] as? UIImageView
                if backgroundImageView != nil && backgroundImageView?.image != nil{
                    debugPrint("log setNeedsNavigationBarBackground 4")

                    barBackgroundView.alpha = alpha
                }else if barBackgroundView.subviews.count >= 2{
                    debugPrint("log setNeedsNavigationBarBackground 5")

                    let backgroundEffectView = barBackgroundView.subviews[1] as? UIVisualEffectView // UIVisualEffectView
                    if (backgroundEffectView != nil) {
                        debugPrint("log setNeedsNavigationBarBackground 6")

                        backgroundEffectView!.alpha = alpha;
                    }
                }
            }else{
                debugPrint("log setNeedsNavigationBarBackground 7")

                barBackgroundView.alpha = alpha
            }
            self.navigationBar.clipsToBounds = true
        }
    }
}

extension UIViewController{
    func formSheetContentSize()->CGSize{
        return CGSize.init(width: 300, height: 432)
    }
    func showAsFormSheet(fromVC:UIViewController,contentSize:CGSize?,naviBarHidden:Bool,completion:(()->Void)?){
        let testNavi:UINavigationController = UINavigationController.init(rootViewController: self)
        testNavi.modalPresentationStyle = .formSheet
        testNavi.preferredContentSize = contentSize ?? self.formSheetContentSize()
        testNavi.setNavigationBarHidden(naviBarHidden, animated: true)
        fromVC.present(testNavi, animated: true) { 
            if completion != nil{
                completion!()
            }
        }
    }
    func dismissFormSheet(completion:(()->Void)?){
        self.navigationController?.dismiss(animated: true , completion: { 
            if completion != nil{
                completion!()
            }
        })
    }
}


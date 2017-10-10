//
//  HMLoginViewController.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/10/10.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class HMLoginViewController: UIViewController {

    let logoImgv:UIImageView = UIImageView.init()
    let nameTf:UITextField = UITextField.init()
    let pwdTf:UITextField = UITextField.init()
    let loginBt:UIButton = UIButton.init(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        self.setupSubviews()
        
        self.view.addCommonTap(target: self , sel: #selector(self.hideKeyboard))
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if HMLoginManager.shared.currentUserName.length > 0 {
            nameTf.text = HMLoginManager.shared.currentUserName
        }
        if HMLoginManager.shared.currentPassword.length > 0 {
            pwdTf.text = HMLoginManager.shared.currentPassword
        }
        
        if nameTf.text?.length ?? 0 > 0 && pwdTf.text?.length ?? 0 > 0 && HMLoginManager.shared.shouldAutoLogin {
            self.loginBt.sendActions(for: .touchUpInside)
        }
    }
    
    func setupSubviews(){
        logoImgv.frame = .init(x: 0, y: 100, width: 120, height: 120)
        logoImgv.image = #imageLiteral(resourceName: "logo")
        
        nameTf.frame = .init(x: 0, y: self.logoImgv.bottom + 25, width: self.view.width * 0.5, height: 40)
        nameTf.placeholder = "内网花名"
        nameTf.borderStyle = .roundedRect
        
        pwdTf.frame = .init(x: 0, y: self.nameTf.bottom + 25, width: self.view.width * 0.5, height: 40)
        pwdTf.placeholder = "密码"
        pwdTf.borderStyle = .roundedRect
        pwdTf.isSecureTextEntry = true
        
        loginBt.frame = .init(x: 0, y: self.pwdTf.bottom + 50, width: self.view.width * 0.5, height: 45)
        loginBt.setTitle("登入", for: .normal)
        loginBt.setTitleColor(colorTitle, for: .normal)
        loginBt.addTarget(self , action: #selector(self.loginBtClick(_:)), for: .touchUpInside)
        loginBt.backgroundColor = colorDefaultBlue
        
        logoImgv.centerX = self.view.centerX
        nameTf.centerX = self.view.centerX
        pwdTf.centerX = self.view.centerX
        loginBt.centerX = self.view.centerX
        
        self.view.addSubview(logoImgv)
        self.view.addSubview(nameTf)
        self.view.addSubview(pwdTf)
        self.view.addSubview(loginBt)
    }

    func hideKeyboard(){
        self.view.becomeFirstResponder()
    }
    
    func showError(message:String){
        let label:UILabel = UILabel.init()
        label.text = message
        label.font = UIFont.systemFont(ofSize: 14)
        label.sizeToFit()
        
        self.view.showToast(label, duration: 3.0, point: self.loginBt.center, completion: nil)
    }
    func loginBtClick(_ sender :UIButton){
        
        
        loginBt.isEnabled = false
        
        let userName:String = nameTf.text ?? ""
        let userPwd:String = pwdTf.text ?? ""
        
        if userName.length > 0 && userPwd.length > 0 {
            self.view.makeToastActivity(loginBt.center)
            
            HMLoginManager.shared.loginWith(userName: userName, password: userPwd, success: {[weak self ] (user ) in
                self?.view.hideToastActivity()
                debugPrint("login success :",user.objID,user.name,user.avatar)
                HMCDManager.shared.userDBName = user.userId
                self?.loginSuccessHandler()
            }, failure: { (error ) in
                self.view.hideToastActivity()
                
                self.showError(message: error)
                self.loginBt.isEnabled = true
            })
        }else{
            loginBt.isEnabled = true
            self.showError(message: "输入有误")
        }
        
    }
    
    func loginSuccessHandler(){
        let mainTabbar = UITabBarController.init()
        let recentsNavi = UINavigationController.init(rootViewController: HMRecentSessionsViewController.init())
        let contactsNavi = UINavigationController.init(rootViewController: HMContactsViewController.init())
        let centerNavi = UINavigationController.init(rootViewController: HMPersonCenterViewController.init())
        
        let item1 = UITabBarItem.init(title: "消息", image: #imageLiteral(resourceName: "conversation"), selectedImage: #imageLiteral(resourceName: "conversation_selected"))
        let item2 = UITabBarItem.init(title: "联系人", image: #imageLiteral(resourceName: "contact"), selectedImage: #imageLiteral(resourceName: "contact_selected"))
        let item3 = UITabBarItem.init(title: "我", image: #imageLiteral(resourceName: "myprofile"), selectedImage: #imageLiteral(resourceName: "myprofile_selected"))
        
        recentsNavi.tabBarItem = item1
        contactsNavi.tabBarItem = item2
        centerNavi.tabBarItem = item3
        
        mainTabbar.setViewControllers([recentsNavi,contactsNavi,centerNavi], animated: true )
        self.navigationController?.pushViewController(mainTabbar, animated: true )
        self.navigationController?.setNavigationBarHidden(true , animated: true )
        self.removeFromParentViewController()
    }
 
}
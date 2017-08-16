//
//  ViewController.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ttt = Im.BaseDefine.DepartInfo.Builder()
        ttt.deptId = 333
        ttt.deptName = "测试"
        ttt.parentDeptId = 33
        ttt.priority = 34
        ttt.deptStatus = .deptStatusOk
        
        if let depInfo = try? ttt.build() {
            print(depInfo.deptName,depInfo.deptId,depInfo.parentDeptId)
        }else {
            print("ViewController test departinfo builded failure")
        }
        
    
        self.view.addCommonTap(target: self , sel: #selector(self.tapAction))
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tapAction(){
        LoginModule.instance().login(withUsername: "qing", password: "qing", success: { (user ) in
            if user != nil {
                RuntimeStatus.instance().user = user!
                RuntimeStatus.instance().updateData()
                DDClientState.shareInstance().userState = .online
                
                debugPrint("testLogin success : ",user!.name ,user!.objID )

            }else{
                debugPrint("testLogin success but not user")
            }
        }) { (logMsg) in
            debugPrint("testLogin error : ",logMsg ?? "")
        }
    }

}


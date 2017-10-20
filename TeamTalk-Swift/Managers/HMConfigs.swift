//
//  HMConfigs.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/10/20.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit


public class HMConfigs: NSObject {

    public class var MsgServerAddress:String{
        get{
            return UserDefaults.standard.string(forKey: "HMConfigs_Msg_Server_Address") ?? ""
        }
        set{
            UserDefaults.standard.setValue(newValue, forKey: "HMConfigs_Msg_Server_Address")
            UserDefaults.standard.synchronize()
        }
    }
    
}

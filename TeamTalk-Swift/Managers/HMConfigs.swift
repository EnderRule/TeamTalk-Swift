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

  
    /// default is true to not print out debug logs.
    public class var disableLog:Bool{
        get{
            if UserDefaults.standard.object(forKey: "HMConfigs_disableLog") != nil {
                return UserDefaults.standard.bool(forKey: "HMConfigs_disableLog")
            }else{
                return true
            }
        }
        set{
            UserDefaults.standard.setValue(newValue, forKey: "HMConfigs_disableLog")
            UserDefaults.standard.synchronize()
        }
    }
}

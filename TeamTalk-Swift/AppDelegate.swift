//
//  AppDelegate.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit
import UserNotifications

//let SERVER_Address = "https://aitlg.linking.im/msg_server"
let SERVER_Address =  "http://192.168.113.31:8080/msg_server"


class Test:MTTUserEntity{
    var fsfl:String = ""
    var fsflr3:String = ""
    var dfs:Int = 0
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        HMConfigs.MsgServerAddress = SERVER_Address
        HMConfigs.disableLog = false
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { (issuccess , error ) in
                debugPrint("application notification requestAuthorization \(issuccess) \(error?.localizedDescription ?? "nil error ")")
            }
        }
        application.registerForRemoteNotifications()
        let notiSettings:UIUserNotificationSettings = UIUserNotificationSettings.init(types: [.alert,.badge,.sound], categories: nil)
        application.registerUserNotificationSettings(notiSettings)
        
        let loginVC = HMLoginViewController.init()
        loginVC.hidesBottomBarWhenPushed = true
        let navivc:UINavigationController = UINavigationController.init(rootViewController: loginVC)
        navivc.setNavigationBarHidden(true  , animated:true)
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.rootViewController = navivc
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("application did fail to register remote : \(error.localizedDescription)")
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = String.init(data: deviceToken, encoding: .utf8) ?? ""
        debugPrint("application did register remote Token:\(deviceTokenString)")
        
        HMLoginManager.shared.pushTtoken = deviceTokenString
    }
    
}


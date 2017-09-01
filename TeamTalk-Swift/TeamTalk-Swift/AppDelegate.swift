//
//  AppDelegate.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/8/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       
        RuntimeStatus.instance()
        DDClientStateMaintenanceManager .shareInstance()
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { (issuccess , error ) in
                debugPrint("application notification requestAuthorization \(issuccess) \(error?.localizedDescription ?? "nil error ")")
            }
        } else {
            application.registerForRemoteNotifications()
        }
        
//        var length:Int = 51
//        let muData:NSMutableData = NSMutableData.init()
//        for index in 0..<4 {
//            var byte = ((length >> ((3 - index)*8)) & 0x0ff)
//            muData.append(&byte, length: 1)
//        }
//        print(muData)
//        muData.append(&length, length: 4)
//        print(muData)
        
        let encodeString = "Qo4lP7wUjxZpDl56invDaYqC2AXu3sSlElta7gLuOAlXKAj0dsogFc8/ZsYCc5EU"
        let decodeString = "{\"type\":10,\"data\":\"{\"text\":\"grededt\"}\"}"
        
        let decoderesult = encodeString.decrypt()
        
        print("decoderesult",decoderesult)
        
        let testString = "fsfsfsefef fs测试哈哈哈哈哈单独累吧😓④发数据考虑f睡覺覅是你"
        let encryptStr = testString.encrypt()
        let decryptStr = encryptStr.decrypt()
        
        print(self.classForCoder,"security test ","\n\(testString)\n\(encryptStr)\n\(decryptStr)")
        
        let loginVC = MTTLoginViewController.init()
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
    }
    
}


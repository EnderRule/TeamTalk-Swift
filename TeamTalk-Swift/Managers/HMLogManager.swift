//
//  HMLogManager.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/10/20.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

public class HMLogManager: NSObject {
    public static  let shared  = HMLoginManager()

}


let defaultDateFormater:DateFormatter = DateFormatter.init()
func stringFor(date:Date)->String{
    defaultDateFormater.dateFormat = "yyyy:MM:dd-HH:mm:ss"
    return defaultDateFormater.string(from: date)
}
func dateFor(str:String)->Date?{
    defaultDateFormater.dateFormat = "yyyy:MM:dd-HH:mm:ss"
    return defaultDateFormater.date(from: str)
}

let disableHMLog:Bool = false

func HMPrint(_ items: Any...,file: String = #file, line: Int = #line , function: String = #function) {
    if !disableHMLog{
        let time = stringFor(date: Date())
        let filename = (file as NSString).lastPathComponent
        
        print("HMPrint \(time)--\(filename)--\(line):",items,"\n")
    }
}

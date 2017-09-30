//
//  NSObject+UpdateValues.swift
//  Linking
//
//  Created by HZQ on 2017/4/11.
//  Copyright © 2017年 online. All rights reserved.
//

import UIKit
import ObjectiveC

extension NSObject{
    
    /**
     获取对象对于的属性值，无对于的属性则返回NIL
     
     - parameter property: 要获取值的属性
     
     - returns: 属性的值
     */
    @objc func getValueOfProperty(property:String)->AnyObject?{
        let allPropertys = self.getAllPropertys()
        if(allPropertys.contains(property)){
            return self.value(forKey: property) as AnyObject?
        }else{
            return nil
        }
    }
    
    /**
     设置对象属性的值
     
     - parameter property: 属性
     - parameter value:    值
     
     - returns: 是否设置成功
     */
    @objc func setValueOfProperty(property:String,value:AnyObject)->Bool{
        let allPropertys = self.getAllPropertys()
        if(allPropertys.contains(property)){
            self.setValue(value, forKey: property)
            return true
            
        }else{
            return false
        }
    }
    
    @objc func getAllPropertys()->[String]{
        return self.getAllPropertys(theClass: self.classForCoder, includeSupers: false )
    }
    
    /**
     获取对象的所有属性名称
     - includeSupers: 是否包含父类的属性名 ,父类为NSObject 除外
     - returns: 属性名称数组
     */
    @objc func getAllPropertys(theClass:AnyClass,includeSupers:Bool)->[String]{
        
        var result = [String]()
        let count = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
        let buff = class_copyPropertyList(theClass, count)
        let countInt = Int(count[0])
        
        for i in 0..<countInt{
            let temp = buff![i]
            let tempPro = property_getName(temp!)
            let proper = String.init(utf8String: tempPro!)
            result.append(proper!)
        }
        free(count)
        
        if includeSupers {
            if let  superclass = theClass.superclass(){
                if superclass != NSObject.classForCoder() {
                    let superresults = self.getAllPropertys(theClass: superclass, includeSupers: true)
                    result.append(contentsOf: superresults)
                }
            }
        }
        
        return result
    }
    
    @objc public convenience init(info:[String:Any]?){
        self.init()
        
        self.updateValues(info:info)
    }
    
    @objc  public func updateValues(info:[String:Any]?){
        if info == nil{
            return
        }else{
            
            let jsonObj = JSON.init(info!)
            for kv in info!{
                let selfProperty = class_getProperty(self.classForCoder, (kv.key as NSString).utf8String)
                if selfProperty != nil{
                    let attribute = String.init(utf8String: property_getAttributes(selfProperty!)) ?? "1,1"
//                    debugPrint("\(self.classForCoder) \(kv.key) Property  attribute:\(attribute)  \(kv.value)")
                    let type:String = attribute.components(separatedBy: ",").first!
                    if type == "Tq" || type == "Ti" || type == "Ts" || type == "Tl"{
                        self.setValue(jsonObj[kv.key].intValue, forKey: kv.key)
                    }else if type == "TQ" || type == "TI" || type == "TS" || type == "TL"{
                        self.setValue(jsonObj[kv.key].uIntValue, forKey: kv.key)
                    }else if type == "Tf"{
                        self.setValue(jsonObj[kv.key].floatValue, forKey: kv.key)
                    }else if type == "Td"{
                        self.setValue(jsonObj[kv.key].doubleValue, forKey: kv.key)
                    }else if type == "T@\"NSString\"" || type == "T@\"NSMutableString\""{
                        self.setValue(jsonObj[kv.key].stringValue, forKey: kv.key)
                    }else if type == "T@\"NSArray\"" || type == "T@\"NSMutableArray\""{
                        self.setValue(jsonObj[kv.key].arrayObject, forKey: kv.key)
                    }else if type == "T@\"NSDictionary\"" || type == "T@\"NSMutableDictionary\""{
                        if let dic = jsonObj[kv.key].dictionaryObject {
                            self.setValue(dic, forKey: kv.key)
                        }else {
                            let jsonstring:String  = jsonObj[kv.key].stringValue
                            do {
                                let jsondic = try   JSONSerialization.jsonObject(with: jsonstring.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.init(rawValue: 0))
                                    self.setValue(jsondic, forKey: kv.key)
                            }catch {
                                debugPrint("\(self.classForCoder)  set valueForKey:\(kv.key) ---- fail 4 property_attribute:\(attribute)")
                            }
                        }
                    }else if type == "T@\"NSNumber\"" {
                        self.setValue(jsonObj[kv.key].numberValue , forKey: kv.key)
                    }else if type == "TB"  {
                        self.setValue(jsonObj[kv.key].boolValue  , forKey: kv.key)
                    }else if type == "T@\"NSDate\""{
                        if let date = info![kv.key] as? Date {
                            self.setValue(date , forKey: kv.key)
                        }else {
                            var dateString = jsonObj[kv.key].stringValue
                            if dateString.length >= 19 {
                                dateString = (dateString as NSString).substring(to: 19)
                                
                                let formater = DateFormatter.init()
                                formater.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                if let date = formater.date(from: dateString){
                                    self.setValue(date , forKey: kv.key)
                                }
                            }
                        }
                    }else if type == "T@\"NSData\"" || type == "T@\"NSMutableData\""{
                        if let data = info![kv.key] as? Data {
                            self.setValue(data , forKey: kv.key)
                        }else {
                            do {
                                let data = try jsonObj[kv.key].rawData()
                                if type == "T@\"NSMutableData\""{
                                    self.setValue(NSMutableData.init(data: data ), forKey: kv.key)
                                }else{
                                    self.setValue(data, forKey: kv.key)
                                }
                            }catch{
                                debugPrint("\(self.classForCoder)  set valueForKey:\(kv.key) ---- fail 3 property_attribute:\(attribute)")
                            }
                        }
                    }else{
                        debugPrint("\(self.classForCoder)  set valueForKey:\(kv.key) ---- fail 3 property_attribute:\(attribute)")
                    }
                }else{
                    debugPrint("\(self.classForCoder)  set valueForKey:\(kv.key) ---- fail 1")
                }
            }
        }
    }
    
    
    func dicValues()->[String:Any]{
        var dic:[String:Any] = [:]
        
        let propertys = self.getAllPropertys(theClass: self.classForCoder, includeSupers: true)
        
        for property in propertys {
            let value = self.value(forKey: property)
            
            if value != nil {
                dic.updateValue(value!, forKey: property)
            }
        }
        return dic
    }
  
    
    func descriptionValues()->String{
    
        let values = self.dicValues()
        
        var description:String = "\(self) values :\n"
        for kv in values{
            
            //格式化对齐
            description.append("\(kv.key)")
            let keylength = kv.key.characters.count
            if keylength < 15 {
                for _ in 0...(20-keylength){
                    description.append(" ")
                }
            }
            description.append(" = \(kv.value)\n")
        }
        return description
    }
    
}

//objc type encoding 参考：https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1
//c  A char
//i  An int
//s  A short
//l  A long l is treated as a 32-bit quantity on 64-bit programs.
//q  A long long
//C  An unsigned char
//I  An unsigned int
//S  An unsigned short
//L  An unsigned long
//Q  An unsigned long long
//f  A float
//d  A double

//            CChar == Int8
//            CShort == Int16
//            CInt == Int32
//            CLong == Int
//            CLongLong == Int64

//print(Int.max)
//print(UInt.max)
//
//print(Int8.max)
//print(UInt8.max)
//
//
//print(Int16.max)
//print(UInt16.max)
//
//print(Int32.max)
//print(UInt32.max)
//
//print(Int64.max)
//print(UInt64.max)
//
//print(CLong.max)

//32位
//        2147483647
//        4294967295
//        127
//        255
//        32767
//        65535
//        2147483647
//        4294967295
//        9223372036854775807
//        18446744073709551615

//64位
//        9223372036854775807
//        18446744073709551615
//        127
//        255
//        32767
//        65535
//        2147483647
//        4294967295
//        9223372036854775807
//        18446744073709551615

//var result2 = [String]()
//let count2 = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
//let buff2 = class_copyIvarList(cls, count2)
//let countInt2 = Int(count[0])
//for i in 0..<countInt2{
//    let temp = buff2![i]
//    if temp != nil{
//        let name = ivar_getName(temp!)
//        let nameStr = String.init(utf8String: name!)
//
//        let type = ivar_getTypeEncoding(temp!)
//        let typeStr = String.init(utf8String: type!)
//
//        debugPrint("property  name:\(nameStr)   type:\(typeStr)")
//        //            result2.append(proper!)
//    }
//}


//参考网络资源：https://segmentfault.com/q/1010000008096189
//unsigned int count;
//
////在运行时创建继承自NSObject的People类
//Class People = objc_allocateClassPair([NSObject class], "People", 0);
//
////完成People类的创建
//objc_registerClassPair(People);
//
//objc_property_attribute_t type = {"T", "@\"NSString\""};
//objc_property_attribute_t attribute2 = {"N",""};//value无意义时通常设置为空
//objc_property_attribute_t ownership = { "C", "" };
//objc_property_attribute_t backingivar = { "V", "_pro"};
//objc_property_attribute_t attrs[] = {type,attribute2, ownership, backingivar};
//
////向People类中添加名为pro的属性,属性的4个特性包含在attributes中
//BOOL y = class_addProperty(People, "pro", attrs, 4);
//NSLog(@"%d",y);
//
////创建People对象p1
//id p1 = [[People alloc]init];
//
//objc_property_t * properties = class_copyPropertyList(People, &count);
//for (int i = 0; i<count; i++) {
//    NSLog(@"属性的名称为 : %s",property_getName(properties[i]));
//    NSLog(@"属性的特性字符串为: %s",property_getAttributes(properties[i]));
//}





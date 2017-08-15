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
    
    /**
     获取对象的所有属性名称
     
     - returns: 属性名称数组
     */
    @objc func getAllPropertys()->[String]{
        
        var result = [String]()
        let count = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
        let buff = class_copyPropertyList(object_getClass(self), count)
        let countInt = Int(count[0])
        
        for i in 0..<countInt{
            let temp = buff![i]
            let tempPro = property_getName(temp!)
            let proper = String.init(utf8String: tempPro!)
            result.append(proper!)
        }
        free(count)
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
                    let attribute = String.init(utf8String: property_getAttributes(selfProperty!))!
//                    debugPrint("\(self.classForCoder) \(kv.key) Property  attribute:\(attribute)  \(kv.value)")
                    
                    if attribute.hasPrefix("T"){
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
                            self.setValue(jsonObj[kv.key].dictionaryObject ?? [:], forKey: kv.key)
                        }else{
                            debugPrint("\(self.classForCoder)  set valueForKey:\(kv.key) ---- fail 3 property_attribute:\(attribute)")
                        }
                    }else{
                        debugPrint("\(self.classForCoder)  set valueForKey:\(kv.key) ---- fail 2")
                    }
                }else{
                    debugPrint("\(self.classForCoder)  set valueForKey:\(kv.key) ---- fail 1")
                }
            }
        }
    }
    
    
    func dicValues()->[String:Any]{
        var dic:[String:Any] = [:]
        
        let propertys = self.getAllPropertys()
        
        for property in propertys {
            let value = self.value(forKey: property)
            
            if value != nil {
                dic.updateValue(value!, forKey: property)
            }
        }
        return dic
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





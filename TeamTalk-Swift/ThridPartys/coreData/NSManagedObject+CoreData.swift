//
//  NSManagedObject+CoreData.swift
//  HMCDManager
//
//  Created by HuangZhongQing on 2017/9/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit
import CoreData
import ObjectiveC



@available (iOS 8.0,*)
extension  NSManagedObject {
    
    static let primaryKeyName:String = "HMCDPrimaryKeyName"
    
    @objc public convenience init(myvalues:[String:Any]?){
        self.init()
        
        
    }
    
//    var primaryKeyName:String = ""
    
    func getThePrimaryKeyName()->String{
        
        let primarykeyName = (objc_getAssociatedObject(self , NSManagedObject.primaryKeyName) as? String ?? "")
        if primarykeyName.characters.count > 0 {
            return primarykeyName
        }
        
        let count = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
        let buff = class_copyPropertyList(self.classForCoder, count)
        let countInt = Int(count[0])
        for i in 0..<countInt{
            let temp = buff![i]
            let tempPro = property_getName(temp!)
            let proper:String = String.init(utf8String: tempPro!)!
            
            if proper == "primaryKeyName"{
                let keyname = self.value(forKey: proper) as? String ?? ""
                
                if keyname.characters.count > 0 {
                    objc_setAssociatedObject(self , NSManagedObject.primaryKeyName, keyname, .OBJC_ASSOCIATION_RETAIN)
                }
                return keyname
            }
        }
        free(count)
        
        return ""
    }
    
    
    class func newNotInertObj()->NSManagedObject{
        let obj = NSEntityDescription.insertNewObject(forEntityName: "\(self)", into: HMCDManager.shared.context)
        obj.db_delete(complettion: nil)
        
        return obj
    }
    
    class func newObj()->NSManagedObject{
        let obj = NSEntityDescription.insertNewObject(forEntityName: "\(self)", into: HMCDManager.shared.context)
        return obj
    }
    
    
    class func checkUnique(obj:NSManagedObject,values:[String:Any]?)->NSManagedObject?{
        let primaryKey:String = obj.getThePrimaryKeyName()
        if primaryKey.characters.count > 0 {
            
            var primaryValue:Any? = obj.value(forKey: primaryKey)
            if primaryValue == nil && values != nil  && ((values! as NSDictionary).allKeys as NSArray).contains(primaryKey) {
                primaryValue = values![primaryKey]
            }
            if primaryValue != nil {
                let predicate:NSPredicate = NSPredicate.init(format: "\(primaryKey) = %@", argumentArray: [primaryValue!])
                var targetObj:NSManagedObject?
                DispatchQueue.global().sync {
                    self.db_query(predicate: predicate, sortBy: nil , sortAscending: true , offset: 0, limitCount: 0, success: { (objs ) in
                        targetObj = objs.first
                    }, failure: nil )
                }
                return targetObj
            }
            
        }
        
        return nil
    }
    
    
    @objc func db_add(values:[String:Any],success:((NSManagedObject)->Void)?, failure:((String)->Void)?){
        //如果主键已存在，插入后将旧的object删除
        if let exist :NSManagedObject = self.classForCoder.checkUnique(obj: self , values: nil ){
            debugPrint("HMCDLog: has exist obj with primarykey value :",exist.value(forKey: exist.getThePrimaryKeyName())!,"will be replace")
            
            HMCDManager.shared.add(entity: self , values: values, success: { (obj ) in
                success?(obj)
                exist.db_delete(complettion: nil)
            }) { (error ) in
                failure?(error)
            }
        }else{
            HMCDManager.shared.add(entity: self , values: values, success: { (obj ) in
                success?(obj)
            }) { (error ) in
                failure?(error)
            }
        }
    }
    
    
    @objc func db_update(completion:((String?)->Void)?){
        
        HMCDManager.shared.update(entity: self , values: nil, success: { (obj ) in
            completion?(nil)
        }) { (error ) in
            completion?(error)
        }
    }
    
    @objc func db_update(values:[String:Any],success:((NSManagedObject)->Void)?, failure:((String)->Void)?){
        
        HMCDManager.shared.update(entity: self , values: values, success: { (obj ) in
            success?(obj)
        }) { (error ) in
            failure?(error)
        }
    }
    
    @objc func db_delete(complettion: ((String?)->Void)?){
        HMCDManager.shared.delete(entity: self) { (error ) in
            complettion?(error)
        }
    }
    
    @objc class func db_deleteAll(complettion: ((String?)->Void)?){
        HMCDManager.shared.delete(entityName: "\(self)") { (error ) in
            complettion?(error)
        }
    }
    
    
    @objc class func db_query(fetchRequest:NSFetchRequest<NSFetchRequestResult>,success:(([NSManagedObject])->Void), failure:((String)->Void)?){
        HMCDManager.shared.query(fetchRequest: fetchRequest, success: { (objs ) in
            success(objs)
        }) { (error ) in
            failure?(error)
        }
    }
    
    @objc class func db_query(offset:Int,limitCount:Int,success:(([NSManagedObject])->Void), failure:((String)->Void)?){
        HMCDManager.shared.query(myclass: self, predicate: nil , sortBy: nil , sortAscending: false , offset: offset, limitCount: limitCount, success: { (objs ) in
            success(objs)
        }) { (error ) in
            failure?(error)
        }
    }
    
    @objc class func db_query(predicate:NSPredicate?,sortBy:String?,sortAscending:Bool,offset:Int,limitCount:Int,success:(([NSManagedObject])->Void), failure:((String)->Void)?){
        HMCDManager.shared.query(myclass: self, predicate: predicate , sortBy: sortBy , sortAscending: sortAscending , offset: offset, limitCount: limitCount, success: { (objs ) in
            success(objs)
        }) { (error ) in
            failure?(error)
        }
    }
}

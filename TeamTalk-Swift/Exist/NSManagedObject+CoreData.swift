//
//  NSManagedObject+CoreData.swift
//  HMCDManager
//
//  Created by HuangZhongQing on 2017/9/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit
import CoreData

@available (iOS 8.0,*)
extension  NSManagedObject {

    @objc public convenience init(myvalues:[String:Any]?){
        self.init()
        
    }
    
    class func newNotInertObj()->NSManagedObject{
        let obj = NSEntityDescription.insertNewObject(forEntityName: "\(self)", into: HMCDManager.shared.context)
        HMCDManager.shared.context.delete(obj)
        return obj
    }
    
    class func newObj()->NSManagedObject{
        let obj = NSEntityDescription.insertNewObject(forEntityName: "\(self)", into: HMCDManager.shared.context)
        return obj
    }
    
    @objc func db_add(values:[String:Any],success:((NSManagedObject)->Void)?, failure:((String)->Void)?){
        HMCDManager.shared.add(entity: self , values: values, success: { (obj ) in
            success?(obj)
        }) { (error ) in
            failure?(error)
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

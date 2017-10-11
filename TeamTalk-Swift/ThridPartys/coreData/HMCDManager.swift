//
//  HMCDManager.swift
//  HMCDManager
//
//  Created by HuangZhongQing on 2017/9/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit
import CoreData

@available (iOS 8.0,*)
class HMCDManager: NSObject {
    static let shared = HMCDManager()
    
    var userDBName:String = ""{
        didSet{
            //dbName变化时，保存当前修改 并重置相关项目
            let _ = self.saveContext()
            self.s_objectModel = nil
            self.s_objectContext = nil
            self.s_storeCoordinator = nil
        }
    }
    open var dbPathUrl:URL{
        get{
            let homeURL:NSURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
//            let version:String = self.objectModel.versionIdentifiers.first as? String ?? ""
//            let versions = (self.objectModel.versionIdentifiers.reversed() as? [String] ?? [])
            let path:URL =  homeURL.appendingPathComponent("HMCDManager\(userDBName).db", isDirectory: true )!
            return path
        }
    }
    var context:NSManagedObjectContext{
        get {
            
            //            if #available(iOS 10.0, *) {
            //                return container.viewContext
            //            } else { 
            return  objectContext
            //            }
        }
    }
    
    //iOS 10以下用的
    private var s_storeCoordinator:NSPersistentStoreCoordinator?
    private var s_objectModel:NSManagedObjectModel?
    private var s_objectContext:NSManagedObjectContext?
    
    private var objectContext:NSManagedObjectContext{
        get{
            if self.s_objectContext != nil {
                return self.s_objectContext!
            }else{
                self.s_objectContext = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
                self.s_objectContext!.persistentStoreCoordinator = self.persistentCoordinator
                
            }
            return  s_objectContext!
        }
    }
    
    @available (iOS 8.0,*)
    private var objectModel: NSManagedObjectModel  {
        get{
            if self.s_objectModel != nil {
                return self.s_objectModel!
            }else {
                self.s_objectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main] )  //合并所有 model
                return self.s_objectModel!
            }
        }
    }
    
    @available (iOS 8.0,*)
    private var persistentCoordinator: NSPersistentStoreCoordinator{
        get{
            if self.s_storeCoordinator != nil {
                return self.s_storeCoordinator!
            }
            self.s_storeCoordinator =  NSPersistentStoreCoordinator.init(managedObjectModel: self.objectModel)
            
            do{

                let options:[AnyHashable:Any] = [NSSQLitePragmasOption:["journal_mode":"DELETE"],NSMigratePersistentStoresAutomaticallyOption:true,NSInferMappingModelAutomaticallyOption:true] //轻量级数据自动迁移
//                @{
//                    NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"},
//                    NSMigratePersistentStoresAutomaticallyOption :@YES,
//                    NSInferMappingModelAutomaticallyOption:@YES
//                };
                try self.s_storeCoordinator?.addPersistentStore(ofType:NSSQLiteStoreType, configurationName: nil , at: self.dbPathUrl, options: options )
            }catch{
                print("add PersistentStore failure \(error.localizedDescription)")
            }
            return self.s_storeCoordinator!
        }
    }
    
    // MARK: - Core Data Saving support
    @available (iOS 8.0,*)
    @objc func saveContext()->Bool {
        
        if context.hasChanges {
            do {
                try context.save()
                return true
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                debugPrint("Unresolved error \(nserror), \(nserror.userInfo)")
                return false
            }
        }
        return true
    }
    
    //MARK:增
    @available (iOS 8.0,*)
    @objc func add(entityName:String,values:[String:Any]?,success:((NSManagedObject)->Void)?, failure:((String)->Void)?){
        
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        let obj = NSManagedObject(entity: entity!, insertInto: context)
        
        for kv in values ?? [:]{
            obj.setValue(kv.value, forKey: kv.key)
        }
        
        //        context.insert(obj)
        do {
            try context.save()
            success?(obj)
        }catch {
            context.rollback()
            failure?("add Error:\(error.localizedDescription)")
        }
    }
    @available (iOS 8.0,*)
    @objc func add(entity:NSManagedObject,values:[String:Any]?,success:((NSManagedObject)->Void)?, failure:((String)->Void)?){
        for kv in values ?? [:]{
            entity.setValue(kv.value, forKey: kv.key)
        }
        //        context.insert(entity)
        do {
            try context.save()
            success?(entity)
        }catch {
            context.rollback()
            failure?("add Error:\(error.localizedDescription)")
        }
    }
    @available (iOS 8.0,*)
    @objc func add(entitys:[NSManagedObject],success:(([NSManagedObject])->Void)?, failure:((String)->Void)?){
        for obj in entitys{
            context.insert(obj)
        }
        do {
            try context.save()
            success?(entitys)
        }catch {
            context.rollback()
            failure?("add Error:\(error.localizedDescription)")
        }
    }
    
    
    //MARK:删
    @available (iOS 8.0,*)
    @objc func delete(entity:NSManagedObject,complettion: ((String?)->Void)?){
        
        context.delete(entity)
        do {
            try context.save()
            complettion?(nil)
        }catch {
            context.rollback()
            complettion?("delete Error:\(error.localizedDescription)")
        }
    }
    @available (iOS 8.0,*)
    @objc func delete(entityName:String,complettion: ((String?)->Void)?){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: entityName)
        self.delete(fetchRequest: fetchRequest) { (error) in
            complettion?(error)
        }
    }
    @available (iOS 8.0,*)
    @objc func delete(fetchRequest:NSFetchRequest<NSFetchRequestResult>,complettion: ((String?)->Void)?){
        do {
            let fetchedResults = try context.fetch(fetchRequest) as? [NSManagedObject]
            for obj in fetchedResults ?? []{
                self.context.delete(obj)
            }
            
            if saveContext() {
                complettion?(nil)
            }else{
                context.rollback()
                complettion?("delete error: failured to save context")
            }
        } catch  {
            complettion?("delete error:\(error.localizedDescription)")
        }
    }
    
    //MARK:改
    @available (iOS 8.0,*)
    @objc func update(entity:NSManagedObject,values:[String:Any]?,success:((NSManagedObject)->Void)?, failure:((String)->Void)?){
        
        for kv in values ?? [:]{
            entity.setValue(kv.value, forKey: kv.key)
        }
        do {
            try context.save()
            success?(entity)
        }catch {
            context.rollback()
            failure?("update Error :\(error.localizedDescription)")
        }
    }
    
    //MARK:查
    @available (iOS 8.0,*)
    @objc func query(fetchRequest:NSFetchRequest<NSFetchRequestResult>,success:(([NSManagedObject])->Void), failure:((String)->Void)?){
        do {
            let fetchedResults = try context.fetch(fetchRequest) as? [NSManagedObject]
            success(fetchedResults ?? [])
        } catch  {
            failure?(error.localizedDescription)
        }
        
    }
    
    @available (iOS 8.0,*)
    @objc func query(myclass:AnyClass,offset:Int,limitCount:Int,success:(([NSManagedObject])->Void), failure:((String)->Void)?){
        self.query(myclass: myclass, predicate: nil , sortBy: nil , sortAscending: false , offset: offset, limitCount: limitCount, success: { (objs ) in
            success(objs)
        }) { (error ) in
            failure?(error)
        }
    }
    
    /// 查询
    ///
    /// - Parameters:
    ///   - myclass:   类名、表名、模型名
    ///   - predicate: <#predicate description#>
    ///   - sortBy: 需要排序的字段
    ///   - sortAscending: 是否升序
    ///   - offset:偏移值
    ///   - limitCount: 0 标示无限制
    ///   - success: 查询成功
    ///   - failure: 查询失败
    @objc func query(myclass:AnyClass,predicate:NSPredicate?,sortBy:String?,sortAscending:Bool,offset:Int,limitCount:Int,success:(([NSManagedObject])->Void), failure:((String)->Void)?){
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "\(myclass)")
        if offset > 0 {
            fetchRequest.fetchOffset = offset
        }
        if limitCount > 0{
            fetchRequest.fetchLimit = limitCount
        }
        if predicate != nil  {
            fetchRequest.predicate = predicate
        }
        if sortBy?.characters.count ?? 0 > 0 {
            let sortdes:MySortor = MySortor.init(key: sortBy!, ascending: sortAscending)
            fetchRequest.sortDescriptors = [sortdes]
        }
        
        do {
            let fetchedResults = try context.fetch(fetchRequest) as? [NSManagedObject]
            success(fetchedResults ?? [])
        } catch  {
            failure?(error.localizedDescription)
        }
        
    }
    
}

//"db user id " "user_1" "qing"
//"db user id " "user_10" "0988666558"
//"db user id " "user_11" "0988666559"
//"db user id " "user_12" "0988666560"
//"db user id " "user_13" "0998887777"
//"db user id " "user_14" "0955666555"
//"db user id " "user_15" "0987654321"
//"db user id " "user_16" "0955888777"
//"db user id " "user_17" "0987444555"
//"db user id " "user_18" "0955888789"
//"db user id " "user_2" "bbb"
//"db user id " "user_3" "aaa"
//"db user id " "user_4" "king"
//"db user id " "user_5" "qing2"
//"db user id " "user_6" "qing3"
//"db user id " "user_7" "0988666555"
//"db user id " "user_8" "0988666556"
//"db user id " "user_9" "0988666557"

/// 修复使用内置api排序导致的以上排序不合格的问题
class MySortor: NSSortDescriptor{
    
    override func compare(_ object1: Any, to object2: Any) -> ComparisonResult {
        
        guard let sortKey = self.key else {
            return super.compare(object1 , to: object2)
        }
        guard  let obj1 = object1 as? NSObject else{
            return super.compare(object1, to: object2)
        }
        guard let obj2 = object2 as? NSObject else {
            return super.compare(object1, to: object2)
        }
        guard let value1 = obj1.value(forKey: sortKey) else {
            return super.compare(object1, to: object2)
        }
        guard let value2 = obj2.value(forKey: sortKey) else {
            return super.compare(object1, to: object2)
        }
        let str1 = "\(value1)"
        let str2 = "\(value2)"
        
        var result :ComparisonResult = self.ascending ? .orderedAscending:.orderedDescending
        if str1.characters.count > str2.characters.count {
            result = .orderedDescending
        }else if str1.characters.count < str2.characters.count{
            result = .orderedAscending
        }else {
            result = str1.compare(str2)
        }
        
        
        if !self.ascending && result == .orderedDescending{
            result = .orderedAscending
        }else if !self.ascending && result == .orderedAscending{
            result = .orderedDescending
        }
        
        return result
    }
    
}


//
//  NSObject+HMDB.swift
//  HMCDManager
//
//  Created by HuangZhongQing on 2017/10/12.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit
import FMDB

@objc public  protocol HMDBModelDelegate:NSObjectProtocol {
    
    
    /// 返回一个 FMDatabaseQueue 实例，数据库的操作将在此实例queue中进行
    ///
    /// - Returns: FMDatabaseQueue 实例
    func db()->Any
    func dbFields()->[String]
    func dbPrimaryKeys()->[String]  //返回多个时代表使用联合主键
    
}


var cachePropertysDic:[String:[objc_property_t]] = [:]

var cachePropertyTypesDic:[String:String] = [:]

public extension NSObject {
    
    static private var kdefaultPK =  "HMDBdefaultPK"
    static private var kisExistInDB =  "HMDBisExistInDB"
    
    class var tableName:String{
        return "\(self.classForCoder())"
    }
    
    var defaultPK:Int{
        get{
            return objc_getAssociatedObject(self , &NSObject.kdefaultPK) as? Int ?? 0
        }
        set{
            objc_setAssociatedObject(self , &NSObject.kdefaultPK, newValue , .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var isExistInDB:Bool{
        get{
            return objc_getAssociatedObject(self , &NSObject.kisExistInDB) as? Bool ?? false
        }
        set{
            objc_setAssociatedObject(self , &NSObject.kisExistInDB, newValue , .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func handleInDBqueue()->FMDatabaseQueue?{
        let dbqueue = (self as? HMDBModelDelegate)?.db() as? FMDatabaseQueue
        return dbqueue
    }
    
    public convenience init(primaryValue:Any,createIfNoneExist:Bool){
        self.init()
        let tableName:String = "\(self.classForCoder)"
        let primaryKey:String =  "defaultPK"
        let pkvalue = NSObject.serialized(value: primaryValue)

        let sql = "select * from \"\(tableName)\" where \"\(primaryKey)\" = ?"
        
        var fieldValues:[AnyHashable:Any ] = [primaryKey:pkvalue]

        
        
        self.handleInDBqueue()?.inDatabase({ (db ) in
          
            let rs =  db.executeQuery(sql , withArgumentsIn: [pkvalue])
            if rs?.next() ?? false{
                if rs!.resultDictionary != nil {
                    fieldValues = rs!.resultDictionary!
                    self.isExistInDB = true
                }
            }
            rs?.close()
            
            self.setValuesWith(fieldValues: fieldValues)
            
            if createIfNoneExist {
                self.isExistInDB = true
                self.dbAdd(completion: nil)
            }
            
        })
    }
    
    
    func getMaxDefaultPK()->Int{
        
        var pk:Int = 0
        
        DispatchQueue.global().sync {
            self.handleInDBqueue()?.inDatabase({ (db ) in
                let tableName:String = "\(self.classForCoder)"
                let sql = "SELECT MAX(defaultPK) as defaultPK  FROM \(tableName)"
                
                let rs = db.executeQuery(sql , withArgumentsIn: [])
                if rs?.next() ?? false {
                    
                    let maxPK = rs!.int(forColumn: "defaultPK")
                    disableHMDBLog ? () : debugPrint("HMDB max defaultPK of \(tableName) \(maxPK) ")
                    rs?.close()
                    pk = Int(maxPK)
                }
            })
        }
        return pk
    }
    
    //MARK:增删改查
    @objc func dbAdd(completion: ((Bool)->Void)?){
        self.dbSave(insert: true , completion: completion)
    }
    @objc func dbUpdate(completion: ((Bool)->Void)?){
        self.dbSave(insert: false , completion: completion)
    }
    
    @objc func dbSave(completion: ((Bool)->Void)?){
        self.dbSave(insert: nil , completion: completion)
    }
    
    private func dbSave(insert:Bool? ,completion:((Bool)->Void)?){
        
        self.handleInDBqueue()?.inDatabase({ (db ) in
        
            let tableName:String = "\(self.classForCoder)"
            let primaryKeys = (self as! HMDBModelDelegate).dbPrimaryKeys()
            
            var dbvalues:[Any] = []
            
            var fields:[String] = ((tableFieldInfos[tableName] ?? [:]) as NSDictionary).allKeys as? [String] ?? []
            for field in fields{
                let dbvalue = self.encodeValueFor(key: field) // NSObject.serialized(value: self.value(forKey: field) ?? "")
                dbvalues.append(dbvalue)
            }
            
            if primaryKeys.count <= 0{
                fields.append("defaultPK")
                
                if insert ?? false {
                    if self.isExistInDB{
                        dbvalues.append(self.defaultPK)
                    }else{
                        dbvalues.append(self.getMaxDefaultPK()+1)
                    }
                }else{
                    dbvalues.append(self.defaultPK)
                }
            }
            
            var action:String = ""
            if insert == nil {
                if self.isExistInDB{
                    action = "replace"
                }else{
                    action = "insert or replace"
                }
            }else if insert!{
            
                action = "insert"
            }else{
                action = "replace"
            }
            
            let columns = (fields as NSArray).componentsJoined(by: "\",\"")
            var valuesHolders = ("" as NSString).padding(toLength: fields.count * 2, withPad: "?,", startingAt: 0)
            valuesHolders = (valuesHolders as NSString).substring(to: valuesHolders.characters.count - 1)
            let sql:String = "\(action) into \"\(tableName)\" (\"\(columns)\") values (\(valuesHolders))"
            
    //        disableHMDBLog ? () : debugPrint("HMDB save sql:\(sql) values:\(dbvalues)")
            
            let result = db.executeUpdate(sql , withArgumentsIn: dbvalues)
            if result{
                self.isExistInDB = true
            }
            completion?(result)
        })
        
    }
    
    
    
    @objc func dbDelete(completion:((Bool)->Void)?){
        self.handleInDBqueue()?.inDatabase({ (db ) in
            let tableName:String = "\(self.classForCoder)"
            
            var primaryKeys = (self as! HMDBModelDelegate).dbPrimaryKeys()
            for obj in primaryKeys{
                if obj.characters.count <= 0 {
                    primaryKeys.remove(at: primaryKeys.index(of: obj)!)
                }
            }
            if primaryKeys.count <= 0{
                primaryKeys = ["defaultPK"]
            }
            
            var sql:String = ""
            var primaryValues:[Any] = []

            if primaryKeys.count == 1 {
                let primaryKey = primaryKeys.first!
                let primaryValue = primaryKey == "defaultPK" ? self.defaultPK : self.encodeValueFor(key: primaryKey)
                primaryValues.append(primaryValue)
                sql = "delete from \(tableName) where \(primaryKey) = ? "
            }else{
                for pkobj in primaryKeys{
                    primaryValues.append(self.encodeValueFor(key: pkobj))
                }
                var valuesHolders = ("" as NSString).padding(toLength: primaryValues.count * 2, withPad: "?,", startingAt: 0)
                valuesHolders = (valuesHolders as NSString).substring(to: valuesHolders.characters.count - 1)
                
                sql = "delete from \(tableName) where (\((primaryKeys as NSArray).componentsJoined(by: ","))) = (\(valuesHolders)) "
            }
            disableHMDBLog ? () : debugPrint("HMDB  delete sql:\(sql) values:\(primaryValues)")
            let result =  db.executeUpdate(sql , withArgumentsIn: primaryValues)
            completion?(result)
        })
    }
    
    /// query
    ///
    /// - Parameters:
    ///   - whereStr: example: objid = 33  or name like "myname"
    ///   - orderFields: example: objid desc,content asce
    ///   - offset: default 0
    ///   - limitCount: default 0
    /// - Returns: entity objs as array
    @objc class func dbQuery(whereStr:String?,orderFields:String?,offset:Int,limit:Int,args:[Any],completion:@escaping (([Any],Error?)->Void)){

        let obj = (self.classForCoder() as! NSObject.Type).init()
        obj.handleInDBqueue()?.inDatabase({ (db ) in
        
            let tableName:String = "\(self.classForCoder())"
            var sql:String = "select * from \(tableName) "
            if whereStr?.characters.count ?? 0 > 0 {
                sql.append(" where \(whereStr!) ")
            }
            if orderFields?.characters.count ?? 0 > 0{
                sql.append(" order by \(orderFields!) ")
            }
            if offset > 0 || limit > 0 {
                sql.append(" limit \(offset),\(limit) ")
            }
//            disableHMDBLog ? () : debugPrint("db query sql:\(sql) values:\(args)")
        
            let rs =  db.executeQuery(sql , withArgumentsIn: args)
            if rs != nil  {
                
                var objs:[AnyObject] = []
                while rs!.next() {
                    let dic = ((rs!.resultDictionary ?? [:]) as NSDictionary).copy() as! [String:Any]
                    let obj = (self.classForCoder() as! NSObject.Type).init()
                    obj.setValuesWith(fieldValues: dic) 
                    objs.append(obj)
                }
                rs?.close()
                completion(objs,nil)
            }else{
                completion([],db.lastError())
            }
        })
    }
    
    //MARK:赋值取值、值的序列化与反序列化
    @objc func setValuesWith(fieldValues:[AnyHashable:Any]){
        for obj in fieldValues{
            let propertyName = obj.key as? String ?? ""
            let type  = NSObject.cachePropertyTypeOf(theClass: self.classForCoder, propertyName: propertyName )
            if type != "NOT_FOUND"{
                self.decode(dbValue: obj.value, forkey: propertyName)
            }
        }
        if fieldValues["defaultPK"] as? Int != nil {
            self.defaultPK = fieldValues["defaultPK"] as! Int
        }
    }
    
    
    private func encodeValueFor(key:String)->Any{
        return (self.classForCoder as! NSObject.Type).serialized(value:self.value(forKey: key) ?? "")
    }
    
    private func decode(dbValue:Any,forkey:String){
        let value = (self.classForCoder as! NSObject.Type).unserialized(dbvalue: dbValue , propertyName: forkey)
        if (value as? NSNull) == nil {  //不为null 才能设置
            self.setValue(value , forKey: forkey)
        }
    }
    
    class func serialized(value:Any)->Any{
        if let array = value as? [Any]{
            do{
                let data = try JSONSerialization.data(withJSONObject: array, options: .init(rawValue: 0))
                
                return self.stringFrom(data: data)
            }catch{
                disableHMDBLog ? () : debugPrint("HMDB can not serialized for array value:\(String(describing: value))")
                return ""
            }
        }else if let dic = value as? [AnyHashable:Any]{
            do{
                let data = try JSONSerialization.data(withJSONObject: dic, options: .init(rawValue: 0))
                return self.stringFrom(data: data)
            }catch{
                disableHMDBLog ? () : debugPrint("HMDB can not serialized for dictionary value:\(String(describing: value))")
                return ""
            }
        }else if let url = value as? URL {
            return url.absoluteString
        }else if let date = value as? Date {
            return date.timeIntervalSince1970
        }else if let data = value as? Data {
            return self.stringFrom(data: data )
        }
        
        return value
    }
    class func unserialized(dbvalue:Any,propertyName:String)->Any{
        
        let type = self.cachePropertyTypeOf(theClass: self.classForCoder(), propertyName: propertyName)
        
//        debugPrint("unserialized \(self.classForCoder()) \(propertyName) \(dbvalue) \(type)  \(type(of: dbvalue))")
 
        
        if type.contains("NSArray")
            || type.contains("NSMutableArray")
            || type.contains("NSDictionary")
            || type.contains("NSMutableDictionary"){
            let str = dbvalue as? String ?? ""
            
            
            let data = self.dataFrom(string: str)
            do {
                let obj = try JSONSerialization.jsonObject(with: data , options: .init(rawValue: 0))
                
                if type.contains("NSArray"){
                    return obj as? [Any] ?? []
                }else if type.contains("NSMutableArray"){
                    return NSMutableArray.init(array:  obj as? [Any] ?? [])
                }else if type.contains("NSDictionary"){
                    return obj as? [AnyHashable:Any] ?? [:]
                }else if type.contains("NSMutableDictionary"){
                    return NSMutableDictionary.init(dictionary: obj as? [AnyHashable:Any] ?? [:])
                }
            }catch{
                disableHMDBLog ? () : debugPrint("HMDB can not unserialized for value:\(String(describing: dbvalue))")
                if type.contains("NSArray"){
                    return []
                }else if type.contains("NSMutableArray"){
                    return NSMutableArray.init(array:  [])
                }else if type.contains("NSDictionary"){
                    return [:]
                }else if type.contains("NSMutableDictionary"){
                    return NSMutableDictionary.init(dictionary: [:])
                }
            }
        }else if type.contains("NSDate"){
            let timeInterval = dbvalue as? Double ?? 0
            return Date.init(timeIntervalSince1970: timeInterval)
        }else if type.contains("NSData") || type.contains("NSMutableData"){
            let str = dbvalue as? String ?? ""
            if type.contains("NSData"){
                return self.dataFrom(string: str)
            }else{
                return NSMutableData.init(data: self.dataFrom(string: str))
            }
        }else if type.contains("NSURL"){
            let str = dbvalue as? String ?? ""
            if let url = URL.init(string: str){
                return url
            }
        }
        return dbvalue
    } 
    
    class func stringFrom(data:Data)->String{
        return String.init(data: data , encoding: .utf8) ?? ""
    }
    class  func dataFrom(string:String)->Data{
        
        return string.data(using: .utf8) ?? Data()
    }
    
    class func cachePropertyTypeOf(theClass:AnyClass,propertyName:String)->String{
        let cacheKey = NSStringFromClass(theClass).appending(propertyName)
        var cacheType = cachePropertyTypesDic[cacheKey]
    
        if cacheType?.characters.count ?? 0 <= 0 {
            var resultType:String?

            let propertys = self.cachePropertysOf(theClass: theClass)
            for property in propertys{
                var tempname = ""
                if let namePointer =  property_getName(property){
                    tempname = String.init(cString: namePointer)
                }
                
                var tempType = ""
                if let typePointer = property_getAttributes(property){
                    tempType = String.init(cString: typePointer)
                }                
                if tempname.characters.count > 0 && tempType.characters.count > 0 {
                    let tempcacheKey = NSStringFromClass(theClass).appending(tempname)
                    cachePropertyTypesDic.updateValue(tempType, forKey: tempcacheKey)
                    
                    if tempname == propertyName{
                        resultType = NSString.init(string: tempType) as String
                    }
                }
            }
            return resultType ?? "NOT_FOUND"
        }
        return cacheType ?? "NOT_FOUND"
    }
    
    class func cachePropertysOf(theClass:AnyClass)->[objc_property_t]{
        let className = NSStringFromClass(theClass)
        
        var result = cachePropertysDic[className] ?? []
        
        if result.count <= 0 {
            let temp = self.getAllPropertysOf(theClass: theClass, includeSupers: true )
            cachePropertysDic.updateValue(temp , forKey: className)
            result = [objc_property_t].init(temp)
        }
        return result
    }
    
    /**
     获取对象的所有属性名称
     - includeSupers: 是否包含父类的属性名 ,父类为NSObject 除外
     - returns: 属性名称数组
     */
    public class func getAllPropertysOf(theClass:AnyClass,includeSupers:Bool)->[objc_property_t]{
        
        var result = [objc_property_t]()
        let count = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
        let buff = class_copyPropertyList(theClass, count)
        let countInt = Int(count[0])
        
        for i in 0..<countInt{
            if  let property = buff![i]{
                result.append(property)
            }
        }
        
        free(count)
        free(buff)
        
        if includeSupers {
            if let  superclass = theClass.superclass(){
                if superclass != NSObject.classForCoder() {
                    let superresults = self.getAllPropertysOf(theClass: superclass, includeSupers: true)
                    result.append(contentsOf: superresults)
                }
            }
        }
        
        return result
    }
    
}


func nameOf(property:objc_property_t)->String{
    if let tempPro = property_getName(property){
        return  String.init(cString: tempPro)
    }
    return ""
}





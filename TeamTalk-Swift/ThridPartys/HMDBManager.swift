//
//  HMDBManager.swift
//
//  Created by HuangZhongQing on 2017/10/12.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit
import Foundation



//import fm
import FMDB


let disableHMDBLog:Bool = true

extension NSObject{
    class func newObjFor(subCls:AnyClass) ->AnyObject{
        
        return  (subCls as! NSObject.Type).init()
    }
}



class HMDBManager: NSObject {
    
    static let shared = HMDBManager()
    
    var modelClasses:[AnyClass] = []
    var dbUserID:String = ""{
        willSet{
            let oldValue = dbUserID
            if newValue != oldValue{
                self.openDB()
            }
        }
    }
    
    
    var classPropertyInfos:[String:[String:String]] = [:]
    var tableFieldInfos:[String:[String:String]] = [:]
    var tablePrimaryKeyName:[String:String] = [:]
    
    var dataBaseQueue:FMDatabaseQueue!
    var dataBase:FMDatabase!
    
    func addDBModelClass(cls:AnyClass){

        self.modelClasses.append(cls)
        if dataBase.open(){
            let _ = self.createTableFor(cls: cls)
        }
    }
    
    var dbPath:String{
        let path = (NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true ).first! as NSString).appendingPathComponent("mydb\(dbUserID).sqlite")
        
        if !FileManager.default.fileExists(atPath: path ){
            FileManager.default.createFile(atPath: path, contents: nil , attributes: nil )
        }
        return path
    }
    
    private var dbVersion:Int{
        get{
            return UserDefaults.standard.integer(forKey: "HMDBVersion")
        }
        set{
            UserDefaults.standard.setValue(newValue, forKey: "HMDBVersion")
            UserDefaults.standard.synchronize()
        }
    }
    private var lastDBVersion:Int{
        get{
            return UserDefaults.standard.integer(forKey: "HMDBLastVersion")
        }
        set{
            UserDefaults.standard.setValue(newValue, forKey: "HMDBLastVersion")
            UserDefaults.standard.synchronize()
        }
    }
    
    
    func openDB(){
        
        if dataBaseQueue != nil{
            dataBaseQueue.close()
        }
        if dataBase != nil {
            dataBase.close()
        }
        
        dataBaseQueue = FMDatabaseQueue.init(path: dbPath)
        dataBase = FMDatabase.init(path: dbPath)
        
        if dataBase.open(){
            
//            if dbVersion > lastDBVersion {
//                self.clearAllTables()
//            }
            
            self.createTables()
        }else{
            
            
        }
        
        
//        dataBaseQueue.inDatabase { (database) in
//            var schemeVersion:Int32 = 0
//            let set = database.executeQuery("PRAGMA user_version", withArgumentsIn: [])
//            if set?.next() ?? false {
//                schemeVersion = set!.int(forColumnIndex: 0)
//            }
//            set?.close()
//            
//            database.beginTransaction()
//            
//        }
        
    }
    
    func createTables() {
        for cls in self.modelClasses{
//            let tableName:String = "\(cls.class())"
//            if !dataBase.tableExists(tableName){
                let _ = self.createTableFor(cls: cls)
//            }
        }
    }
    func createTableFor(cls:AnyClass)->Bool{
        let tableName = "\(cls)"

        let sql:String = self.sqlOfCreateTable(cls:cls)
        if sql.characters.count == 0 {
            return false 
        }
        
        dataBase.shouldCacheStatements = true
        if !dataBase.executeUpdate(sql , withArgumentsIn: []) {
            return false
        }
        
        var currentColumns:[String] = []
        let rs = dataBase.getTableSchema(tableName)
        while rs.next(){
            let dic = rs.resultDictionary ?? [:]
            let column = dic["name"] as? String ?? ""
            
            if column.characters.count > 0 {
                currentColumns.append(column)
            }
        }
        
        var shouldAddColumns:[String] = []
        
        let expectedColumns = ((tableFieldInfos[tableName] ?? [:]) as NSDictionary).allKeys as! [String]
        for obj in expectedColumns{
            if !currentColumns.contains(obj){
                shouldAddColumns.append(obj)
            }
        }
        
        for column in shouldAddColumns{
            let sqltype = self.sqlTypeOf(cls: cls, field: column).last!
            if sqltype.characters.count > 0 {
                if  !self.alertTable(cls: cls , addColumn: column, type: sqltype){
                    disableHMDBLog ? () : debugPrint("fail to alert table \(tableName) add column \(column) \(sqltype)")
                }
            }
        }
        return true
        
    }
    
    func alertTable(cls:AnyClass,addColumn:String,type:String)->Bool{
        
        let tableName = "\(cls)"
        
        let sql = "alter table \(tableName) add \(addColumn) \(type)"
        
        return self.dataBase.executeStatements(sql )
    }
    
    func alertTable(cls:AnyClass,alertColumn:String,newType:String)->Bool{
        let tableName = "\(cls)"
        
        let sql = "alter table \(tableName) alert column \(alertColumn) \(newType)"
        
        return self.dataBase.executeStatements(sql )

    }
    
    func alertTable(cls:AnyClass,deleteColumn:String)->Bool{
        
        let tableName = "\(cls)"
        
        let sql = "alter table \(tableName) drop \(deleteColumn)"
        
        return self.dataBase.executeStatements(sql )
    }
    
    func clearAllTables(){
        for cls in self.modelClasses{
            let tableName:String = "\(cls.class())"
            if !dataBase.tableExists(tableName){
                let _ = self.clearTable(name: tableName)
            }
        }
    }
    func clearTable(name:String)->Bool{
        dataBase.shouldCacheStatements = true
        return dataBase.executeUpdate("delete from %@", withArgumentsIn: [name])
    }
    
    func sqlOfCreateTable(cls:AnyClass)->String{
        
        let tableName:String = "\(cls)"
        var colums:String = ""
        
        if let obj = (cls as! NSObject.Type).init() as? HMDBModelDelegate {
            
            let storeFields = obj.dbFields()
            let primaryKey = obj.dbPrimaryKey() ?? ""
            
            var realDbFields:[String:String] = [:]
            var classPropertyTypes:[String:String] = [:]
            
            let properties = (obj as! NSObject).getAllPropertys(theClass: cls , includeSupers: true )
            
            for field in storeFields{
                
                if properties.contains(field){
                    
                    let types = self.sqlTypeOf(cls: cls , field: field)
                    let sqlType = types.last!
                    let rawType = types.first!
                    
                    if sqlType.characters.count > 0 {
                        if primaryKey == field{
                            colums.append("\(field) \(sqlType) primary key,")
                            
                            tablePrimaryKeyName.updateValue(field, forKey: tableName)
                        }else{
                            colums.append("\(field) \(sqlType),")
                        }
                        realDbFields.updateValue(sqlType, forKey: field)
                        classPropertyTypes.updateValue(rawType, forKey: field)
                    }
                }
                
                if primaryKey.characters.count == 0 {
                    colums.append("defaultPK integer primary key")
                    tablePrimaryKeyName.updateValue("defaultPK", forKey: tableName)
                }
                
                tableFieldInfos.updateValue(realDbFields, forKey: tableName)
                classPropertyInfos.updateValue(classPropertyTypes, forKey: tableName)
            }
            
            if colums.hasSuffix(","){
                colums = (colums as NSString).substring(to: colums.characters.count - 1)
            }
        }else{
            disableHMDBLog ? () : debugPrint("class \(cls) is not in db handled ")
        }
        
        if colums.characters.count == 0 {
            disableHMDBLog ? () : debugPrint("create table \(tableName) but has no surported dbFields")
            return ""
        }
        return "CREATE TABLE IF NOT EXISTS \(tableName) (\(colums))"
    }
    
    
    func sqlTypeOf(cls:AnyClass,field:String)->[String]{

        let property = class_getProperty(cls, field)
        let attribute = String.init(utf8String: property_getAttributes(property)) ?? "1,1"
        
        let rawType:String = attribute.components(separatedBy: ",").first!
        var sqlType:String = ""
        
        if rawType == "Tq" || rawType == "Ti" || rawType == "Ts" || rawType == "Tl"{
            sqlType = "integer"
        }else if rawType == "TQ" || rawType == "TI" || rawType == "TS" || rawType == "TL"{
            sqlType = "integer"
        }else if rawType == "Tf"{
            sqlType = "single"
        }else if rawType == "Td"{
            sqlType = "double"
        }else if rawType == "TB"  { //bool 值
            sqlType = "integer"
        }else if rawType.contains("NSDate"){
            sqlType = "double"
        }else if rawType.contains("NSURL"){
            sqlType = "text"
        }else if rawType.contains("NSData") || rawType.contains("NSMutableData"){
            sqlType = "text"
        }else if rawType.contains("NSString") || rawType.contains("NSMutableString"){
            sqlType = "text"
        }else if rawType.contains("NSArray") || rawType.contains("NSMutableArray"){
            sqlType = "text"
        }else if rawType.contains("NSDictionary") || rawType.contains("NSMutableDictionary"){
            sqlType = "text"
        }else if rawType.contains("NSNumber") {
            sqlType = "double"
        }else{
            disableHMDBLog ? () : debugPrint("database not surport for type of \(field)")
        }
        
        return [rawType,sqlType]
    }
}



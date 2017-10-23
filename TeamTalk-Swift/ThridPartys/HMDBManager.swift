//
//  HMDBManager.swift
//  HMCDManager
//
//  Created by HuangZhongQing on 2017/10/12.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit
import Foundation




import FMDB

let disableHMDBLog:Bool = false 

extension NSObject{
    class func newObjFor(subCls:AnyClass) ->AnyObject{
        
        return  (subCls as! NSObject.Type).init()
    }
}

var tableFieldInfos:[String:[String:String]] = [:]


public class HMDBManager: NSObject {
    
    public static let shared = HMDBManager()
    
    public var modelClasses:[AnyClass] = []
    var dbUserID:String = ""
    
    public var dataBaseQueue:FMDatabaseQueue!
    
    public func addDBModelClass(cls:AnyClass){

        self.modelClasses.append(cls)
        
        dataBaseQueue.inDatabase { (db ) in
            if db.open(){
                let _ = self.createTableFor(cls: cls,database: db)

            }
        }
    }
    
    public var currentDBPath:String{
        get{
            return dbPath
        }
    }
    
    private var dbPath:String{
        let path = (NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true ).first! as NSString).appendingPathComponent("mydb\(dbUserID).sqlite")
        
        if !FileManager.default.fileExists(atPath: path ){
            FileManager.default.createFile(atPath: path, contents: nil , attributes: nil )
        }
        return path
    }
    
    override init() {
        super.init()
    }
    
    public func openDB(userID:String){
        
        if dataBaseQueue != nil{
            dataBaseQueue.close()
        }
        
        dataBaseQueue = FMDatabaseQueue.init(path: dbPath)
        dataBaseQueue.inDatabase({ (db ) in

//                var lastDBVersion:Int = 0
//                let rs = db.executeQuery("PRAGMA user_version", withArgumentsIn: [])
//                if rs?.next() ?? false {
//                    lastDBVersion = Int(rs!.int(forColumnIndex: 0))
//                }
//                rs?.close()
//                
//                let newversion = dbVersionBuilder(lastDBVersion)
//                debugPrint("new db version:\(newversion) lastV:\(lastDBVersion)")
//                if newversion > lastDBVersion{
//                    if !db.executeUpdate("PRAGMA user_version = \(newversion)", withArgumentsIn: []){
//                        disableHMDBLog ? () : debugPrint("update DB user_version \(newversion) failure ")
//                    }
//                }
            
        //创建表
            for cls in self.modelClasses{
                let _ = self.createTableFor(cls: cls,database: db )
            }
        })
    }
    
    private func createTableFor(cls:AnyClass,database:FMDatabase)->Bool{
        let tableName = "\(cls)"
        
        var currentColumns:[String] = []
        var currentPrimarykeys:[String] = []
        let rs = database.getTableSchema(tableName)
        while rs.next(){
            let dic = rs.resultDictionary ?? [:]
            let column = dic["name"] as? String ?? ""
            
            if rs.bool(forColumn: "pk"){
                currentPrimarykeys.append(column)
            }
//            disableHMDBLog ? () : debugPrint("\(tableName) \(column) \(rs.bool(forColumn: "pk") ? "is":"is not") primaryKey")
            
            if column.characters.count > 0 {
                currentColumns.append(column)
            }
        }
        rs.close()
        
        //检查主键是否改变，如果有改变，需将原有的table删除
        if let obj = (cls as! NSObject.Type).init() as? HMDBModelDelegate{
            var primarykeyFields = obj.dbPrimaryKeys()
            if primarykeyFields.count <= 0 {
                primarykeyFields = ["defaultPK"]
            }

            let currentFieldsStr:String = (currentPrimarykeys.sorted() as NSArray).componentsJoined(by: ",")
            let newFieldsStr:String = (primarykeyFields.sorted() as NSArray).componentsJoined(by: ",")

            if currentFieldsStr != newFieldsStr && database.tableExists(tableName){

                let dropResult = self.dropTable(cls: cls , database: database )
                
                disableHMDBLog ? () : debugPrint("\(tableName) primarykey fields had changed from \(currentFieldsStr) to \(newFieldsStr),\(dropResult) to delete exist table")
                
            }
        }
        
        let sql:String = self.sqlOfCreateTable(cls:cls)

        if sql.characters.count == 0 {
            return false
        }
        
        database.shouldCacheStatements = true
        
        let createResult = database.executeUpdate(sql , withArgumentsIn: [])
//        disableHMDBLog ? () : debugPrint("\(createResult) create table \(tableName) SQL:\(sql)")

        if !createResult {
            return false
        }
        
        var shouldAddColumns:[String] = []
        
        let expectedColumns = ((tableFieldInfos[tableName] ?? [:]) as NSDictionary).allKeys as! [String]
        for obj in expectedColumns{
            if !currentColumns.contains(obj){
                shouldAddColumns.append(obj)
            }
        }
        for column in shouldAddColumns{
            let rawtype = NSObject.cachePropertyTypeOf(theClass: cls , propertyName: column)
            let sqltype = self.sqlTypeOfProperty(rawType: rawtype)
            if sqltype.characters.count > 0 {
                if  !self.alertTable(cls: cls , addColumn: column, type: sqltype,database:database){
                    disableHMDBLog ? () : debugPrint("fail to alert table \(tableName) add column \(column) \(sqltype)")
                }
            }
        }
        
        return true
        
    }
    
    func alertTable(cls:AnyClass,addColumn:String,type:String,database:FMDatabase)->Bool{
        
        let tableName = "\(cls)"
        
        let sql = "alter table \(tableName) add \(addColumn) \(type)"
        
        return database.executeStatements(sql )
    }
    
    func alertTable(cls:AnyClass,alertColumn:String,newType:String,database:FMDatabase)->Bool{
        let tableName = "\(cls)"
        
        let sql = "alter table \(tableName) alert column \(alertColumn) \(newType)"
        
        return database.executeStatements(sql )
    }
    
    func alertTable(cls:AnyClass,deleteColumn:String,database:FMDatabase)->Bool{
        
        let tableName = "\(cls)"
        
        let sql = "alter table \(tableName) drop \(deleteColumn)"
        
        return database.executeStatements(sql )
    }
    
    func dropTable(cls:AnyClass,database:FMDatabase)->Bool{
        let tableName = "\(cls)"
        
        let sql = "drop table \(tableName)"
        
        return database.executeStatements(sql )
    }
    
    func clearAllTables(){
        for cls in self.modelClasses{
            let tableName:String = "\(cls.class())"
            self.clearTable(name: tableName)
        }
    }
    func clearTable(name:String){
        dataBaseQueue.inDatabase { (db ) in
            db.shouldCacheStatements = true
            db.executeUpdate("delete from \(name)", withArgumentsIn: [])
        }
    }
    
    func sqlOfCreateTable(cls:AnyClass)->String{
        
        let tableName:String = "\(cls)"
        var colums:String = ""
        
        var primaryKeys:[String] = []
        if let obj = (cls as! NSObject.Type).init() as? HMDBModelDelegate {
            
            let storeFields = obj.dbFields()
            
            primaryKeys = obj.dbPrimaryKeys()
            if primaryKeys.count <= 0 {
                primaryKeys = ["defaultPK"]
            }
            
            var realDbFields:[String:String] = [:]
            
            for field in storeFields{
                let rawType = NSObject.cachePropertyTypeOf(theClass: cls , propertyName: field)
                
                let sqlType = self.sqlTypeOfProperty(rawType: rawType)

                if sqlType.characters.count > 0 {
                    colums.append("\(field) \(sqlType),")
                    
                    realDbFields.updateValue(sqlType, forKey: field)
                }
            }
            if primaryKeys.first! == "defaultPK"{
                colums.append("defaultPK integer")
                realDbFields.updateValue("integer", forKey: "defaultPK")
            }
            
            tableFieldInfos.updateValue(realDbFields, forKey: tableName)
            
            if colums.hasSuffix(","){
                colums = (colums as NSString).substring(to: colums.characters.count - 1)
            }
            
            if colums.characters.count == 0 {
                debugPrint("create table \(tableName) but has no surported dbFields")
                return ""
            }
            var primaryFieldsStr = ""
            if  primaryKeys.count == 1 {
                primaryFieldsStr = primaryKeys.first!
            }else{
                primaryFieldsStr = (primaryKeys as NSArray).componentsJoined(by: ",")
            }
            let createTableSQL =  "CREATE TABLE IF NOT EXISTS \(tableName)(\(colums),primary key(\(primaryFieldsStr)))" //
            
            return createTableSQL
        }else{
            debugPrint("class \(cls) is not in db handled ")
            return ""
        }
    }
    
    
    func sqlTypeOfProperty(rawType:String)->String{

        let subRawType:String = rawType.components(separatedBy: ",").first ?? ""
        
        var sqlType:String = ""
        if subRawType == "Tq" || subRawType == "Ti" || subRawType == "Ts" || subRawType == "Tl"{
            sqlType = "integer"
        }else if subRawType == "TQ" || subRawType == "TI" || subRawType == "TS" || subRawType == "TL"{
            sqlType = "integer"
        }else if subRawType == "Tf"{
            sqlType = "single"
        }else if subRawType == "Td"{
            sqlType = "double"
        }else if subRawType == "TB"  { //bool 值
            sqlType = "integer"
        }else if subRawType.contains("NSDate"){
            sqlType = "double"
        }else if subRawType.contains("NSURL"){
            sqlType = "text"
        }else if subRawType.contains("NSData") || subRawType.contains("NSMutableData"){
            sqlType = "text"
        }else if subRawType.contains("NSString") || subRawType.contains("NSMutableString"){
            sqlType = "text"
        }else if subRawType.contains("NSArray") || subRawType.contains("NSMutableArray"){
            sqlType = "text"
        }else if subRawType.contains("NSDictionary") || subRawType.contains("NSMutableDictionary"){
            sqlType = "text"
        }else if subRawType.contains("NSNumber") {
            sqlType = "double"
        }else{
            debugPrint("database not surport for type of \(subRawType)")
        }
        
        return sqlType
    }
}



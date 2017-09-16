//
//  HMDBSQLManager.swift
//  TeamTalk-Swift
//
//  Created by HuangZhongQing on 2017/9/15.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit


class HMDBSQLManager: NSObject {

    var database:SQLiteManager = SQLiteManager.shareInstance
    
    let sql_createT_User:String = "CREATE TABLE IF NOT EXISTS T_User(id text PRIMARY KEY,name TEXT,age INTEGER);"
    
    private var currentUserID:String = "user_0"
    var dbFilePath:String{
        get{
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
            let filePath = (path as NSString).appendingPathComponent("HMdatebase_\(self.currentUserID).sqlite")
            if !FileManager.default.fileExists(atPath: filePath){
                FileManager.default.createFile(atPath: filePath, contents: nil , attributes: nil )
            }
            return filePath
        }
    }
    
    func openUserDataBase(userID:String){
        
        self.currentUserID = userID
        
        let _ = database.openDataBase(dbFilePath: dbFilePath)
        
        
    }
    
    
}


import UIKit

class SQLiteManager: NSObject {
    
    //1.单例
    static let shareInstance: SQLiteManager = SQLiteManager()
    
    private var s_currentDBPath:String = ""
    
    public var currentDBFilePath:String {
        return s_currentDBPath
    }
    
    //定义数据库
    var db: OpaquePointer? = nil
    //2.1创建数据库方法
    func openDataBase(dbFilePath:String)->Bool{
        
        guard let cFilePath = dbFilePath.cString(using: .utf8)else{
            return false
        }
        
        self.closeDataBase()  // 关闭之前的库
        
        sqlite3_open(cFilePath, &db)
        self.s_currentDBPath = dbFilePath
        return true
    }
    
    func closeDataBase(){
        if db != nil {
            sqlite3_finalize(db)
        }
        db = nil
        self.s_currentDBPath = ""
    }
    
    //2.2创建表方法，通过执行sql创建表
    func createTable(sql:String ) ->Bool{
        guard db != nil else {
            return false
        }
        
        return execSQL(sql: sql)
    }
    func deleteTable(tableName:String)->Bool{
        guard db != nil else {
            return false
        }
        
        return execSQL(sql: "DELETE FROM \(tableName)")
    }
    
    func execSQL(sql: String)->Bool{
        
        guard db != nil else {
            return false
        }
        
        if sqlite3_exec(db, sql, nil, nil, nil) != SQLITE_OK{
            return false
        }
        return true
    }
    //3.执行sql语句
    //这里执行sql语句进行相应的增删改查、
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    func execSQL(sql: String, args: CVarArg...)->Bool{
        
        guard db != nil else {
            return false
        }
        
        //1.编写sql语句
        guard let csql = sql.cString(using: .utf8) else{
            return false
        }
        
        var stmt: OpaquePointer? = nil
        
        //2.对sql进行预编译，检查sql语句是否有错误
        if  sqlite3_prepare_v2(db, csql, -1, &stmt, nil) != SQLITE_OK{
            return false
        }
        
        //3.遍历参数，将参数绑定在sql语句上
        var index: Int32 = 1
        for arg in args{
            if arg is Int{
                let temp = Int32(arg as! Int)
                sqlite3_bind_int(stmt, index, temp)
            }else if arg is Double{
                let temp = Double(arg as! Double)
                sqlite3_bind_double(stmt, index, temp)
            }else if arg is String{
                
                let temp = String(arg as! String)
                guard let cTemp = temp?.cString(using: .utf8) else{
                    continue
                }
                sqlite3_bind_text(stmt, index, cTemp, -1, SQLITE_TRANSIENT)
            }else{
                print("Other")
            }
            index += 1
        }
        
        //4.执行sql语句
        if sqlite3_step(stmt) != SQLITE_DONE{
            return false
        }

        

        //5.关闭
        sqlite3_finalize(stmt)

        return true
    }
}

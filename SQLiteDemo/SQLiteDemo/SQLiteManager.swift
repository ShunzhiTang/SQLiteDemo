//  SQLiteManager.swift
//  SQLiteDemo
//  Created by Tsz on 15/10/25.
//  Copyright © 2015年 Tsz. All rights reserved.

import Foundation

/**
* sqlite3.h 是C语言的框架 、函数都是以sqlite3_ 开始的
*/

//实现SQLite管理器
class SQLiteManager {
    
    //单例
    static let shareManager = SQLiteManager()
    //全局的数据库 '句柄'handler ， 通常就是一个指向结构体的指针，他可以实现对数据库的操作 ，在前面 我们用他来实现文件的操作
    
    private var db: COpaquePointer = nil
    
    //数据库操作串行队列，使用多线程去执行
    private let queue = dispatch_queue_create("tszSqlite", DISPATCH_QUEUE_SERIAL)
    
    
    //MARK: 打开数据库
    func openDB(dbName: String) {
        
        //生成数据库完整的路径 , 获取沙盒 document的路径
        let path = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask , true).last! as NSString).stringByAppendingPathComponent(dbName)
        print("沙盒下的路径:" + path)
        
        /**
        * 参数：
        * @param path: 数据库的完整路径，bate5 可以直接打开
        * @param db  : 数据库的 '句柄'
        *
        如果数据库存在 就会直接打开  ，如果数据库不存在会新建数据库在打开
        */
        
        //MARK: 根据路径和句柄去 打开数据库
        if sqlite3_open(path, &db) != SQLITE_OK {
            print("打开数据库失败")
            return
        }
        
        //判断 打开数据表
        if createTable() {
            print("创建表成功")
        }else{
             print("创建表失败")
        }
    }
    
    //MARK: 多线程队列更新数据,把自己的行为传递过去
    func queueUpdate(action: (manager: SQLiteManager) ->()){
        
        dispatch_async(queue) { () -> Void in
            //1、开启事务
            self.beginTransaction()
            
            //2、执行任务
            action(manager: self)
            
            //3、提交事务
            self.commitTransaction()
        }
    }
    
    //MARK: 开启事务
    func beginTransaction() {
        execSQL("BEGIN TRANSACTION;")
    }
    
    //MARK: 事务的回滚
    func rollbackTransaction() {
        execSQL("ROLLBACK TRANSACTION;")
    }
    //MARK: 提交事务
    func commitTransaction() {
        execSQL("COMMIT TRANSACTION")
    }
    
    //MARK: 预编译
    // CVarArgType ，多个参数
    func prepareUpdate(sql: String , args: CVarArgType...) -> Bool{
        
        //1、准备sql
        var stmt: COpaquePointer = nil
        
        if sqlite3_prepare_v2(db, sql, -1,&stmt, nil) != SQLITE_OK {
            print("SQL错误")
            return false
        }
        
        //2、遍历绑定数据，从1开始
        var index: Int32 = 1
        for value in args {
            
            //根据不同的类型去绑定
            if value is Int {
                sqlite3_bind_int64(stmt,index, sqlite3_int64(value as! Int))
            }else if value is Double {
                sqlite3_bind_double(stmt, index, value as! Double)
            }else if  value is String {
                sqlite3_bind_text(stmt, index, value as! String , -1 , SQLITE_TEXT_TYPE)
            }else if value is NSNull {
                sqlite3_bind_null(stmt, index)
            }
             index++
        }
       
        //3、执行sql单步
        var result = true
        if sqlite3_step(stmt) != SQLITE_DONE {
            result = false
            print("更新数据失败")
        }
        //4、为了保证 可以复用需要复位
        if sqlite3_reset(stmt) != SQLITE_OK{
            result = false
            print("SQL重置失败")
        }
        //5、释放stmt
        sqlite3_finalize(stmt)
        
        return result
    }
    
    //MARK: text类型的定义
    private let SQLITE_TEXT_TYPE = unsafeBitCast(-1, sqlite3_destructor_type.self)
    
    
    //MARK: 创建数据表
    private func createTable() ->Bool {
        
        //创建表的sql 语句
        let sql = "CREATE TABLE \n" +
        "IF NOT EXISTS 'T_Student' ( \n" +
        "'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,\n" +
        "'name' TEXT, \n" +
        "'age' INTEGER,\n" +
        "'height' REAL,\n" +
        "'title' TEXT \n"  +
        ");"
        //执行sql
        return execSQL(sql)
    }
    
    //MARK: 执行Sql ，创建表
    func execSQL(sql: String) -> Bool {
        /**
        参数：
        1、db全局句柄
        2、要执行的sql
        3、callBack执行sql完毕回调的函数，通常是nil
        4、第四个参数回调函数的第一个参数的地址 ，通常也是nil
        5、错误信息字符串的地址 ，一般也不需要
        
        */
        return (sqlite3_exec(db, sql, nil, nil, nil) == SQLITE_OK)
    }
    
    
    //MARK: 插入表数据
    
    func execInsert(sql: String) -> Int {
        
        //执行sql语句
        if sqlite3_exec(db, sql, nil, nil, nil) == SQLITE_OK{
            
            //返回自增长的id
            return Int(sqlite3_last_insert_rowid(db))
        }
        
        return -1
    }
    
    //MARK: 执行sql语句返回的结果集
    
    
    func execRecordSet(sql: String) -> [[String : AnyObject]]?{
        // 1. 准备 SQL，预先编译 SQL
        /**
        参数
        1. db 数据库句柄
        2. sql 执行的 sql
        3. sql 语句字节的长度，但是 -1 能够自动计算
        4. stmt 语句的指针，后续的查询操作，全部依赖这个指针
        相当于编译好的 sql
        需要`释放`
        5. 尾部参数，通常设置为 nil
        */
        
        //定义一个指针
        var stmt: COpaquePointer = nil
        //预编译sql
        if sqlite3_prepare_v2(db , sql, -1, &stmt, nil) != SQLITE_OK{
            print("SQL 语句有错误！")
            return nil
        }
        
        print("SQL正确")
        
        //定义一个字典数组 ，存储查询的结果的集合
        var recordSet = [[String : AnyObject]]()
        
        // sqlite3_step `单步`执行sql 每调用一次，就获得一个结果
        // SQLITE_ROW 表示获得一条row记录
        while sqlite3_step(stmt) == SQLITE_ROW {
            //添加到数组
                recordSet.append(recordDict(stmt))
            }
        //释放语句

        sqlite3_finalize(stmt)
    
        //返回结果数组
        return  recordSet
    }
    
    //MARK: 从stmt 语句提取单条记录的字典
    private func recordDict(stmt: COpaquePointer) -> [String : AnyObject] {
        
        /**
        * 再继续操作就是针对`行` 一条记录，每条记录应该有多个字段
        */
        
        
        //1、每一行有多少个 '字段' cols ,获得列数
        let  colCount = sqlite3_column_count(stmt)
        
        //一个字典记录单条数据记录
        var dict = [String : AnyObject]()
        
        
        //2、知道每一列字段的名字和内容
        for col in 0..<colCount {
            
            //获取 每一个字段名
            
            let cName = sqlite3_column_name(stmt, col)
            //cName 是一种c语言的字符，需要去转换 uint8 ccChar
            let name = String(CString: cName, encoding: NSUTF8StringEncoding)
            
            //获取每一列的数据类型
            let type = sqlite3_column_type(stmt, col)
            
            //根据不同的类型 去获取不同的值
            
            //定义全局变量记录不同类型的值
            var value: AnyObject?
            switch type {
            case SQLITE_INTEGER:
                value =  Int(sqlite3_column_int64(stmt, col))
            case SQLITE_FLOAT:
                value = sqlite3_column_double(stmt, col)
                
            case SQLITE3_TEXT:
                //转换格式
                let cValue = UnsafePointer<Int8>(sqlite3_column_text(stmt, col))
                value = String(CString: cValue, encoding: NSUTF8StringEncoding)
            case SQLITE_NULL:
                value = NSNull()
            default:
                print("不支持的数据类型！！！")
            }
            
            //给我们字典 赋值
            dict[name!] = value ?? NSNull()
    }
    return dict
  }
}
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
    
    //MARK: 打开数据库
    func openDB(dbName: String) {
        
        //生成数据库完整的路径 , 获取沙盒 document的路径
        let path = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask , true).last! as NSString).stringByAppendingPathComponent(dbName)
        print(path + "沙盒下的路径")
        
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
        
        print(sql)
        
        //执行sql
        return execSQL(sql)
    }
    
    //MARK: 执行Sql ，创建表
    func execSQL(sql: String) -> Bool {
        
        return (sqlite3_exec(db, sql, nil, nil, nil) == SQLITE_OK)
    }
    
    
}
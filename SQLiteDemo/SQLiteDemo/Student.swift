//
//  Student.swift
//  SQLiteDemo
//
//  Created by Tsz on 15/10/26.
//  Copyright © 2015年 Tsz. All rights reserved.
//

import UIKit

class Student: NSObject {

    var id: Int =  0
    var name:String?
    var age: Int = 0
    var height: Double = 0
    
    var title:String?
    
    //重写字典转模型
    init(dict: [String: AnyObject]){
        
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    
    // MARK: 实现数据库的插入
    func insertStudent() ->Bool{
 /// 加断言
        assert(name != nil ,"姓名不能为空")
        
        //定义执行的sql 语句
        let sql = "insert into T_Student(name , age, height,title)\n" + "VALUES('\(name!)' ,\(age),\(height),'\(title!)');"
        
        //执行sql 语句 ，知道 自动增长的id，否则无法正常的更新模型
        id = SQLiteManager.shareManager.execInsert(sql)
        
        return id > 0
    }
    
    //MARK: 删除表中的某一条数据
    func deleteStudent() ->Bool {
        assert( id > 0 , "ID不正确")
        
        //定义sql语句
        let sql = "DELETE FROM T_Student where id = \(id)"
        
        return SQLiteManager.shareManager.execSQL(sql)
    }
    // MARK: 更新表的一条记录
    func updateStudent() ->Bool {
        assert(name != nil, "姓名不能为空")
        assert(id > 0, "id 不正确")
        //定义sql语句
        let sql = "update T_Student set name = '\(name!)' ,age =\(age) , height =\(height),title='\(title!)' where id= \(id);"
        
        return SQLiteManager.shareManager.execSQL(sql)
        
    }
    //MARK: 查询20条数据
    
    class func students() ->[Student]? {
        //sql 查询语句
        let sql = "select * from T_Student LIMIT 10;"
        
        //执行 进行判断
        guard let array = SQLiteManager.shareManager.execRecordSet(sql) else {
            return nil
        }
        //遍历数组，字典转模型
        var arrayM = [Student]()
        for dict in array {
            arrayM.append(Student(dict: dict))
        }
        return arrayM
    }
}

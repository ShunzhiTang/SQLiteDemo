//
//  ViewController.swift
//  SQLiteDemo
//  Created by Tsz on 15/10/25.
//  Copyright © 2015年 Tsz. All rights reserved.

/// 数据库的名字  Person.sqlite
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       //数据库的 测试
//        insertData()
//        updateData()
//        deleteData()
        
//       let result =  Student.students()
        
//        print(result)
        insertData()
        
    }
    
    /// 测试插入10000条数据需要 54.89秒 ，那么当操作大批量的数据的时间要用到事务，默认不开启事务
    //开启事务的是 0.8秒
    
    
    
    func insertData(){
        
        var flag:Bool = false
        
        //swift中两种获取当前系统时间的方法
//        var time1  = NSDate.timeIntervalSinceReferenceDate()
        var time = CFAbsoluteTimeGetCurrent()
  
        let sql = "insert into T_Student(name , age, height,title)\n" + "VALUES(? ,?,?,?);"
           //开启事务：
        SQLiteManager.shareManager.beginTransaction()
        for i in 0..<20 {
           
           flag =  SQLiteManager.shareManager.prepareUpdate(sql, args: "lisi\(i)" ,29 + i,1.8,"xuexi")
        }
        
        //提交事
        SQLiteManager.shareManager.commitTransaction()
        time = CFAbsoluteTimeGetCurrent() - time

        print("时间差：\(time)")
        if flag{
            print("插入成功")
        } else {
            print("插入失败")
        }
    }
    
    //Mark: 删除数据库中的数据
    
    //删除的操作需要 格外的谨慎 ，一定要去指定唯一标识符
    func deleteData(){
    
        //传入一个 id ,传入一个字典就好了
        let dict = ["id" : 1]
        
        if Student(dict: dict).deleteStudent() {
            print("delete success")
        }else {
            print("delete fail")
        }
        
    }
    
    //MARK: 更新数据也要注意一定要去指定唯一标识符
    func updateData(){
        
        //准备需要更新的数据
        let dict = ["name" : "jac33k" ,"age" : 22 ,"height" : 180.3 , "title" : "java111" ,"id" : 3]
        
        if Student(dict: dict).updateStudent(){
            print("update success")
        }else {
            print("update success")
        }
    }

    
}


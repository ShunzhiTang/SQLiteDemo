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
        
       let result =  Student.students()
        
        print(result)
    }
    
    // 插入数据
    var flag: Bool = false
    /// 测试插入10000条数据需要 54.89秒 ，那么当操作大批量的数据的时间要用到事务，默认不开启事务
    //开启事务的是 0.8秒
    
    //swift中两种获取当前系统时间的方法
    var time1  = NSDate.timeIntervalSinceReferenceDate()
    var time = CFAbsoluteTimeGetCurrent()
    
    func insertData(){
        //开启事务：
        SQLiteManager.shareManager.execSQL("BEGIN TRANSACTION")

        for i in 0..<20 {
            let dict = ["name": "zhangsan" , "age" : 19+i ,"height": 180.2 , "title" : "好好学习"]
            let stu =  Student(dict: dict as! [String :AnyObject])
            //执行插入数据的动作
           flag  = stu.insertStudent()
            
        }
        //提交事务
        SQLiteManager.shareManager.execSQL("COMMIT TRANSACTION")
        
        time = CFAbsoluteTimeGetCurrent() - time
         time1 = NSDate.timeIntervalSinceReferenceDate() - time1
        print("时间差：\(time)  + NSDate\(time1)")
        
        if flag {
            print("插入数据成功")
        }else {
            print("插入数据失败")
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


//
//  ViewController.swift
//  Test_FMDB
//
//  Created by  bochb on 2019/5/20.
//  Copyright © 2019 com.heron. All rights reserved.
//

import UIKit
import FMDB
class ViewController: UIViewController {

    let path = "/data.db"
    var db: FMDatabase!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createDatbase()
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        createTable()
//        insert()
//        insertOrIgnore()
//        delete()
//        updata()
//        selectAllData()
//        selectData()
//        transaction()
//        order()
        dbQueue()
    }
    
    //保证数据库线程安全
    func dbQueue() {
        //数据库保存路径
        let str = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!.appending(path)
        let queue = FMDatabaseQueue(path: str)
        queue?.inDatabase({ (db) in
                guard let res = db.executeQuery("select * from students order by id desc", withArgumentsIn: []) else{
                    print("No data")
                    return
                }
                while res.next(){
                    print(res.int(forColumn: "id"))
                }
        })
    }
    
    
    //取出所有数据, 将id按照倒序排列
    func order() {
        if db.open(){
            guard let res = db.executeQuery("select * from students order by id desc", withArgumentsIn: []) else{
                print("No data")
                db.close()
                return
            }
            while res.next(){
                print(res.int(forColumn: "id"))
            }
            db.close()
        }
    }
    //事务
    func transaction() {
        if db.open(){
            db.beginTransaction()
            //删除name为Lily的数据
            db.executeUpdate("delete from students where name=?", withArgumentsIn: ["Lily"])
//            db.rollback()
            db.commit()
            db.close()
        }
    }
    //待条件的查询
    func selectData() {
        if db.open() {
            guard let rs = db.executeQuery("select name from students where id=5", withArgumentsIn: []) else {
                print("No data")
                db.close()
                return
            }
            while rs.next() {
                let name =  rs.string(forColumn: "name")
                print(name)
            }
        }
        db.close()
    }
    //查询所有数据
    func selectAllData() {
        if db.open() {
           
            guard let rs = db.executeQuery("select * from students", withArgumentsIn: []) else {
                print("No data")
                db.close()
                return
            }
            while rs.next() {
              let name =  rs.string(forColumn: "name")
                print(name)
            }
        }
        db.close()
    }
    //更新
    func updata() {
        if db.open() {
            db.executeUpdate("update students set name=?, okkk=? where id=6;", withArgumentsIn: ["Lily",11])
        }
    }
    //删除某条记录
    func delete() {
        if db.open() {
            db.executeUpdate("delete from students where id=10;", withArgumentsIn: [10, "Lucy"])
            db.close()
        }
    }
    //防止重复插入
    func insertOrIgnore() {
        if db.open() {
            //insert or replace
            //insert or ignore
            db.executeUpdate("insert or replace into students (id, name) values (?,?);", withArgumentsIn: [10, "Lucy"])
            db.close()
        }
    }
    
    //插入数据
    func insert() -> Void {
         if db.open() {
            db.executeUpdate("insert into students (name) values (?);", withArgumentsIn: ["Jack"])
            db.close()
        }
    }
    //建表
    func createTable() -> Void {
        if db.open() {
            if !db.tableExists("students"){
                db.executeStatements("create table students(id integer, name text, primary key(id));")
        }else{
            print("students exist already")
        }
    }
}
    //创建数据库
    func createDatbase() {
        //数据库保存路径
        let str = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!.appending(path)
        
        db = FMDatabase(path: str)
    }
        
    
}


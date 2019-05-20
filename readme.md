
FMDB是iOS平台的SQLite数据库框架. 它以OC的方式封装了SQLite的C语言API.但是在使用FMDB的过程中,仍然要自己编写SQL语句.我们只有掌握好了SQL语句, 才能将FMDB运用自如, 本文主要是介绍FMDB的主要使用方法, 具体的SQL语句可以在文[末的连接中查找](#link).具体Demo请点击


### 对比SQLite

FMDB的优点非常明显:

- 使用起来更加面向对象，省去了很多麻烦、冗余的c语言代码

- 对比苹果自带的Core Data框架，更加轻量级和灵活

- 提供了多线程安全的数据库操作方法，有效地防止数据混乱


缺点:

- 因为它是OC的语言封装的，只能在ios开发的时候使用，所以在实现跨平台操作的时候存在局限性。
 
### FMDB基本类

- FMDatabase

一个FMDatabase对象就代表一个单独的SQLite数据库

用来执行SQL语句

- FMResultSet

使用FMDatabase执行查询后的结果集

- FMDatabaseQueue

用于在多线程中执行多个查询或更新，它是线程安全的


基本使用方法如下:

### 创建数据库

    //创建数据库
    func createDatbase() {
        //数据库保存路径
        let str = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!.appending(path)
        db = FMDatabase(path: str)
    }
    
### 创建表

    //建表
    func createTable() -> Void {
        if db.open() {
            if !db.tableExists("students"){
                db.executeStatements("create table students(id integer, name text);")
        }else{
            print("students exist already")
        }
    }
	}

### 插入数据
SQLite 的 INSERT INTO 语句用于向数据库的某个表中添加新的数据行。

INSERT INTO 语句有两种基本语法，如下所示：

	INSERT INTO TABLE_NAME [(column1, column2, column3,...columnN)]  
	VALUES (value1, value2, value3,...valueN);

在这里，column1, column2,...columnN 是要插入数据的表中的列的名称。


如果要为表中的所有列添加值，您也可以不需要在 SQLite 查询中指定列名称。但要确保值的顺序与列在表中的顺序一致。SQLite 的 INSERT INTO 语法如下：

	INSERT INTO TABLE_NAME VALUES (value1,value2,value3,...valueN);

代码如下:

    func insert() -> Void {
         if db.open() {
            db.executeUpdate("insert into students (id, name) values (?,?);", withArgumentsIn: [1, "Jack"])
            db.close()
        }
    }
    
#### 防止插入重复数据

	insert or replace：如果不存在就插入，存在就更新 
	insert or ignore：如果不存在就插入，存在就忽略 

<mark>注意: 只对UNIQUE或者PRIMARY KEY约束的字段起作用。</mark>

    //防止重复插入
    func insertOrIgnore() {
        if db.open() {
            //insert or replace
            //insert or ignore
            db.executeUpdate("insert or replace into students (id, name) values (?,?);", withArgumentsIn: [10, "Lucy"])
            db.close()
        }
    }
    
### 删除某条记录  
  SQLite 的 DELETE 查询用于删除表中已有的记录。可以使用带有 WHERE 子句的 DELETE 查询来删除选定行，否则所有的记录都会被删除。

带有 WHERE 子句的 DELETE 查询的基本语法如下：

	DELETE FROM table_name
	WHERE [condition];

您可以使用 AND 或 OR 运算符来结合 N 个数量的条件。

    //删除某条记录
    func delete() {
        if db.open() {
            db.executeUpdate("delete from students where id=10;", withArgumentsIn: [10, "Lucy"])
            db.close()
        }
    }

### 更新
SQLite 的 UPDATE 查询用于修改表中已有的记录。可以使用带有 WHERE 子句的 UPDATE 查询来更新选定行，否则所有的行都会被更新。

带有 WHERE 子句的 UPDATE 查询的基本语法如下：

	UPDATE table_name
	SET column1 = value1, column2 = value2...., columnN = valueN
	WHERE [condition];
	
您可以使用 AND 或 OR 运算符来结合 N 个数量的条件。

    //更新
    func updata() {
        if db.open() {
            db.executeUpdate("update students set name=?, okkk=? where id=6;", withArgumentsIn: ["Lily",11])
        }
    }
    
###  查询
SQLite 的 SELECT 语句用于从 SQLite 数据库表中获取数据，以结果表的形式返回数据。这些结果表也被称为结果集。

SQLite 的 SELECT 语句的基本语法如下：

	SELECT column1, column2, columnN FROM table_name;

在这里，column1, column2...是表的字段，他们的值即是您要获取的。如果您想获取所有可用的字段，那么可以使用下面的语法：

	SELECT * FROM table_name;

**查询所有数据**

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
    
待条件的查询

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
    
###  事务（Transaction）

事务（Transaction）是一个对数据库执行工作单元。事务（Transaction）是以逻辑顺序完成的工作单位或序列，可以是由用户手动操作完成，也可以是由某种数据库程序自动完成。

事务（Transaction）是指一个或多个更改数据库的扩展。例如，如果您正在创建一个记录或者更新一个记录或者从表中删除一个记录，那么您正在该表上执行事务。重要的是要控制事务以确保数据的完整性和处理数据库错误。
实际上，您可以把许多的 SQLite 查询联合成一组，把所有这些放在一起作为事务的一部分进行执行。

#### 事务的属性

事务（Transaction）具有以下四个标准属性，通常根据首字母缩写为 ACID：

- 原子性（Atomicity）：确保工作单位内的所有操作都成功完成，否则，事务会在出现故障时终止，之前的操作也会回滚到以前的状态。

- 一致性（Consistency)：确保数据库在成功提交的事务上正确地改变状态。

- 隔离性（Isolation）：使事务操作相互独立和透明。

- 持久性（Durability）：确保已提交事务的结果或效果在系统发生故障的情况下仍然存在。

#### 事务控制

使用下面的命令来控制事务：

- BEGIN TRANSACTION：开始事务处理。

- COMMIT：保存更改，或者可以使用 END TRANSACTION 命令。

- ROLLBACK：回滚所做的更改。

事务控制命令只与 DML 命令 INSERT、UPDATE 和 DELETE 一起使用。他们不能在创建表或删除表时使用，因为这些操作在数据库中是自动提交的。

BEGIN TRANSACTION 命令

事务（Transaction）可以使用 BEGIN TRANSACTION 命令或简单的 BEGIN 命令来启动。此类事务通常会持续执行下去，直到遇到下一个 COMMIT 或 ROLLBACK 命令。不过在数据库关闭或发生错误时，事务处理也会回滚。以下是启动一个事务的简单语法：

	BEGIN;
	
	or 
	
	BEGIN TRANSACTION;

#### COMMIT 命令

COMMIT 命令是用于把事务调用的更改保存到数据库中的事务命令。

COMMIT 命令把自上次 COMMIT 或 ROLLBACK 命令以来的所有事务保存到数据库。

COMMIT 命令的语法如下：

	COMMIT;

	or
	
	END TRANSACTION;

#### ROLLBACK 命令
ROLLBACK 命令是用于撤消尚未保存到数据库的事务的事务命令。

ROLLBACK 命令只能用于撤销自上次发出 COMMIT 或 ROLLBACK 命令以来的事务。

ROLLBACK 命令的语法如下：

	ROLLBACK;


实例代码:

    //事务
    func transaction() {
        if db.open(){
            db.beginTransaction()
            //删除name为Lily的数据
            db.executeUpdate("delete from students where name=?", withArgumentsIn: ["Lily"])
            //下面语句二选一执行, 如果只执行第一句,那么删除后会回滚, 数据依然存在(一般用于在事务执行过程中出错时还原数据); 如果只执行第二句, 那么数据会直接被删除
            //db.rollback()
            db.commit()
            db.close()
        }
    }
    


### 排序

SQLite 的 ORDER BY 子句是用来基于一个或多个列按升序或降序顺序排列数据。

ORDER BY 子句的基本语法如下：

	SELECT column-list 
	FROM table_name 
	[WHERE condition] 
	[ORDER BY column1, column2, .. columnN] [ASC | DESC];
	
示例代码:

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
    
    
### FMDB线程安全: 
在多个线程中同时使用一个FMDatabase实例是不明智的。现在你可以为每 个线程创建一个FMDatabase对象，不要让多个线程分享同一个实例，他无 法在多个线程中同事使用。否则程序会时不时崩溃或者报告异常。所以，不要 初始化FMDatabase对象，然后在多个线程中使用。这时候，我们就需要使 用FMDatabaseQueue来创建队列执行事务。

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
    


### 附件: SQLite基础知识

#### SQLite学习笔记六: 约束NOT NULL,DEFAULT,UNIQUE,PRIMARY KEY, CHECK


约束是在表的数据列上强制执行的规则。这些是用来限制可以插入到表中的数据类型。这确保了数据库中数据的准确性和可靠性。

约束可以是列级或表级。列级约束仅适用于列，表级约束被应用到整个表。

**以下是在 SQLite 中常用的约束。**

- NOT NULL 约束：确保某列不能有 NULL 值。

- DEFAULT 约束：当某列没有指定值时，为该列提供默认值。

- UNIQUE 约束：确保某列中的所有值是不同的。

- PRIMARY Key 约束：唯一标识数据库表中的各行/记录。

- CHECK 约束：CHECK 约束确保某列中的所有值满足一定条件。

- NOT NULL 约束
默认情况下，列可以保存 NULL 值。如果您不想某列有 NULL 值，那么需要在该列上定义此约束，指定在该列上不允许 NULL 值。

- NULL 与没有数据是不一样的，它代表着未知的数据。



例如，下面的 SQLite 语句创建一个新的表 COMPANY，并增加了五列，其中 ID、NAME 和 AGE 三列指定不接受 NULL 值：

	   ID INT PRIMARY KEY     NOT NULL,
	
	   NAME           TEXT    NOT NULL,
	
	   AGE            INT     NOT NULL,
	
	   ADDRESS        CHAR(50),


DEFAULT 约束
DEFAULT 约束在 INSERT INTO 语句没有提供一个特定的值时，为列提供一个默认值。


例如，下面的 SQLite 语句创建一个新的表 COMPANY，并增加了五列。在这里，SALARY 列默认设置为 5000.00。所以当 INSERT INTO 语句没有为该列提供值时，该列将被设置为 5000.00。

	   ID INT PRIMARY KEY     NOT NULL,
	
	   NAME           TEXT    NOT NULL,
	
	   AGE            INT     NOT NULL,
	
	   ADDRESS        CHAR(50),
	
	   SALARY         REAL    DEFAULT 50000.00


UNIQUE 约束
UNIQUE 约束防止在一个特定的列存在两个记录具有相同的值。在 COMPANY 表中，例如，您可能要防止两个或两个以上的人具有相同的年龄。



例如，下面的 SQLite 语句创建一个新的表 COMPANY，并增加了五列。在这里，AGE 列设置为 UNIQUE，所以不能有两个相同年龄的记录：

	   ID INT PRIMARY KEY     NOT NULL,
	
	   NAME           TEXT    NOT NULL,
	
	   AGE            INT     NOT NULL UNIQUE,
	
	   ADDRESS        CHAR(50),
	
	   SALARY         REAL    DEFAULT 50000.00


PRIMARY KEY 约束
PRIMARY KEY 约束唯一标识数据库表中的每个记录。在一个表中可以有多个 UNIQUE 列，但只能有一个主键。在设计数据库表时，主键是很重要的。主键是唯一的 ID。

我们使用主键来引用表中的行。可通过把主键设置为其他表的外键，来创建表之间的关系。由于"长期存在编码监督"，在 SQLite 中，主键可以是 NULL，这是与其他数据库不同的地方。

主键是表中的一个字段，唯一标识数据库表中的各行/记录。主键必须包含唯一值。主键列不能有 NULL 值。

一个表只能有一个主键，它可以由一个或多个字段组成。当多个字段作为主键，它们被称为复合键。

如果一个表在任何字段上定义了一个主键，那么在这些字段上不能有两个记录具有相同的值。



已经看到了我们创建以 ID 作为主键的 COMAPNY 表的各种实例：

	   ID INT PRIMARY KEY     NOT NULL,
	
	   NAME           TEXT    NOT NULL,
	
	   AGE            INT     NOT NULL,
	
	   ADDRESS        CHAR(50),


CHECK 约束
CHECK 约束启用输入一条记录要检查值的条件。如果条件值为 false，则记录违反了约束，且不能输入到表。



例如，下面的 SQLite 创建一个新的表 COMPANY，并增加了五列。在这里，我们为 SALARY 列添加 CHECK，所以工资不能为零

	   ID INT PRIMARY KEY     NOT NULL,
	
	   NAME           TEXT    NOT NULL,
	
	   AGE            INT     NOT NULL,
	
	   ADDRESS        CHAR(50),
	
	   SALARY         REAL    CHECK(SALARY > 0)
	   
	   
	   
	   
参考:

<h4 id="link"></h4>
[基本sql语句参考](https://www.runoob.com/sqlite/sqlite-alter-command.html)
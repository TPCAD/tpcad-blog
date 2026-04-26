# MySQL

在 ArchLinux 上使用 MariaDB 替代 MySQL。

使用密码登录 root 用户。

```bash
mariadb -u root -p
```

创建用户，并允许外部 IP 访问。

```sql
create user 'username'@'%' identified by 'password';
flush privileges;
```

授权用户远程访问，并允许所有数据库权限。

```sql
grant all privileges on *.* to 'username'@'%' identified by 'password' with grant option;
```

修改`/etc/my.cnf.d/server.cnf`，允许所有 IP 访问。修改后重启`mariadb.service`服务。

```language
[mysqld]
bind-address=0.0.0.0
```

## DDL

### Databases

#### Create Database

```sql
create database [if not exists] <name> [chracter set <encode>];
```

#### Drop Database

```sql
drop database [if exists] <name>;
```

#### Show Database

```sql
show databases;
```

#### Use Database

```sql
use <name>;
```

### Tables

进行表操作前必须使用`use`指定数据库。

#### Create Table

```sql
create table <table_name> ( <field_name> <type> [constraint]... );

create table student (
    id int,
    name varchar(20),
    age int,
    gender varchar(10),
    score decimal(4,1)
);
```

#### Show Tables

```sql
show tables;
```

#### Show Table description

```sql
desc <database_name>.<table_name>;
```

#### Drop Table

```sql
drop table [if exists] <table_name>
```

#### Alternate Table Structure

##### Add Field

```sql
alter table <table_name> add <field_name> <field_type> [constraint];
```

若字段名与关键字冲突，可使用<code>&#96;</code>包裹关键字。

##### Alternate Field

```sql
alter table <table_name> change <old_field_name> <new_field_name> <field_type> [constraint];

-- 只修改字段名
alter table catagory change description `desc` varchar(20);
-- 只修改类型
alter table catagory change description description varchar(30);
```

##### Drop Field

```sql
alter table <table_name> drop <field_name>;
```

##### Rename Table

```sql
rename table <old_table_name> to <new_table_name>;
```

## DML

### Insert Data

插入数据的字段顺序必须完全遵守表定义的顺序或指定的顺序。

```sql
insert into <table_name> values ( <field_value>... )...;

-- 插入一项数据
insert into student values ( 1, "amber", 20, "female", 80 );
-- 插入多项数据
insert into student values ( 1, "amber", 20, "female", 80 ), ( 2, "eula", 20, "female", 80 );
-- 插入时省略部分字段
insert into student values ( 1, "amber", 20 );

-- 指定插入字段顺序
insert into <table_name> ( <field_name>... ) values ( <field_value>... )...;

-- 插入一项数据
insert into student ( id, name, gender ) values ( 1, "amber", "female" );
-- 插入多项数据
insert into student ( id, name, gender ) values ( 1, "amber", "female" ), ( 2, "eula", "female" );
```

### Update Data

不指定条件的`update`将作用于所有数据项。

```sql
update <table_name> set <field_name>=<field_value>... [where condition];
```

### Delete Data

不指定条件的`delete`将删除所有数据项。

```sql
delete from <table_name> [where condition];

-- 清空表
truncate table <table_name>;
```

`truncate`同样可以清空表，但它属于 DDL，因为`truncate`会先将整张表删除再新建表，而`delete`会一条一条删除匹配的数据项。

## Constraint

### Primary Key

**主键约束**唯一标识表中的一条数据，具有唯一性，非空性。主键通常是一个字段，但也可以多个字段组成**联合主键**。

```sql
-- 建表时在字段描述处指定字段为主键
create table student (
    id int primary key,
    name varchar(20)
);

-- 建表时在约束区指定字段为主键
create table person (
    first_name varchar(20),
    last_name varchar(20),
    primary key (first_name, last_name) -- 指定字段为主键
);

-- 建表后修改主键约束
alter table person add primary key (first_name, last_name);

-- 删除主键约束
alter table person drop primary key;
```

#### Auto Incrementation

`auto_increment`可以在数据插入时自动增加整型字段的值。默认从 1 开始。

```sql
create table student (
    id int primary key auto_increment, -- 指定自动增长列
    name varchar(20)
);

-- 插入时，自动增长列可以为空
insert into student values ( NULL, "alpha" );
-- 插入时，手动指定自动增长列
insert into student values ( 100, "beta" );
-- 插入时，省略自动增长列
insert into student ( name ) values ( "beta" );

-- 修改自动增长起始值
alter table student auto_increment=100;
```

### Not Null

**非空约束**强制要求字段不能为 NULL。

```sql
-- 建表时在字段描述处指定字段非空
create table person (
    id int not null, -- 非空约束
    last_name varchar(20) not null, -- 非空约束
    first_name varchar(20),
    address varchar(20),
    city varchar(20)
);

-- 删除字段非空约束
alter table student change id id int;    -- 不指定非空约束即可删除非空约束
alter table student modify id int;
```

### Unique

**唯一约束**唯一标识表中的一条数据。主键自动拥有唯一约束。一张表只能拥有一个主键，但可以拥有多个具有唯一约束的字段。唯一约束允许为空，允许联合唯一约束。

```sql
create table person (
    id int not null,
    last_name varchar(20) not null,
    first_name varchar(20),
    address varchar(20),
    city varchar(20),
    phone varchar(20) unique -- 唯一约束
);

-- 使用 `drop key` 删除唯一约束
alter table person drop key phone;
```

### Default Value

```sql
create table person (
    id int not null,
    last_name varchar(20) not null,
    first_name varchar(20),
    address varchar(20),
    city varchar(20) default "Beijing", -- 设置默认值
    phone varchar(20) unique
);

-- 删除默认值，不设置即可
alter table person change city city varchar(20);
```

## DQL

```sql
select [distinct] *|<field_name> as <alias>... from <table_name> as <alias> [where condition];
```

### Condition

- 比较运算符：大于、小于等等
- 逻辑运算符：`and`，`or`，`not`
- `between ... and ...`：符合某一闭区间（等价于 `>= and <=`）
- `in ()`：符合某一集合
- `like ''`：模糊搜索字符串
- `is [not] null`：是否为空

```sql
-- 查询所有 pname == 'Levono' 的项
select * from product where pname = 'Levono';
-- 查询 price == 800 的项
select pname from product where price = 800;
-- 查询 price != 800 的项
select pname from product where price != 800;
-- 查询 price >= 60 的项
select * from product where price >= 60;
-- 查询 price >= 80 and price <= 200 的项
select pname from product where price between 80 and 200;
select pname from product where price >= 80 and price <= 200;
-- 查询 price == 80 or price == 200 的项
select pname from product where price = 80 or price = 200;
select pname from product where price in (80, 200);
-- 查询所有 pname 字段含有 'vo' 的项
select pname from product where pname like '%vo%';
-- 查询所有 pname 字段以 'L' 开头的项
select pname from product where pname like 'L%';
-- 查询所有 pname 字段第二个字符是 'e' 的项
select pname from product where pname like '_e%';
-- 查询所有 category_id 为空的项
select pname from product where category_id is null;
-- 查询所有 category_id 不为空的项
select pname from product where category_id is not null;
```

### Sort

```sql
select *|<field_name>[ as <alias>]... from <table_name> [where condition] [order by <field_name [asc|desc]>...];
```

`order by`语句将数据按指定列升序或降序排序，多个排序字段会以第一个字段排序后，再在第一个字段相同的数据里按第二个字段排序。

### Aggregation

聚合查询需要用到 SQL 函数。SQL 函数出现在`select`之后，作为一个`<field_name>`，统计一列的数据并返回一个值。SQL 函数会忽略 NULL 值。

常用 SQL 函数：

| SQL 函数 | 效果                                                       |
| -------- | ---------------------------------------------------------- |
| count()  | 统计指定列不为 NULL 的行数                                 |
| sum()    | 计算指定列的数值和，若字段类型不是数值则返回 0             |
| max()    | 计算指定列的最大值，若字段类型是字符串则使用字符串排序运算 |
| min()    | 计算指定列的最小值，若字段类型是字符串则使用字符串排序运算 |
| avg()    | 计算指定列的平均值，若字段类型不是数值则返回 0             |


### Group

```sql
select *|<field_name>[ as <alias>]... from <table_name> [where condition] [group by <field_name> [having <condition>]];
```

`group by`语句将数据按指定字段分组（值相同为一组）。分组必定伴随聚合，分组后`select`后只能出现分组字段或聚合函数。`having`子句类似`where`子句，但`having`作用于分组后的数据。

### Example

```sql
create database if not exists school_db;
use school_db;

create table student_scores (
    id int primary key auto_increment,
    name varchar(50) not null,
    gender enum('男', '女') not null,
    class varchar(20) not null,
    subject varchar(30) not null,
    score decimal(5,2) not null
);

INSERT INTO student_scores (name, gender, class, subject, score) VALUES
    ('张三', '男', '高三(1)班', '数学', 92.5),
    ('李四', '男', '高三(2)班', '数学', 88.0),
    ('王芳', '女', '高三(1)班', '数学', 95.5),
    ('赵敏', '女', '高三(3)班', '数学', 76.0),
    ('刘伟', '男', '高三(2)班', '英语', 82.5),
    ('陈静', '女', '高三(1)班', '英语', 91.0),
    ('杨洋', '男', '高三(3)班', '英语', 68.5),
    ('周杰', '男', '高三(1)班', '物理', 87.0),
    ('林琳', '女', '高三(2)班', '物理', 93.5),
    ('郭强', '男', '高三(3)班', '物理', 79.0),
    ('马超', '男', '高三(2)班', '数学', 85.5),
    ('黄蓉', '女', '高三(1)班', '英语', 89.0),
    ('诸葛亮', '男', '高三(3)班', '物理', 98.5);

-- 降序排列数学成绩
select * from student_scores where subject='数学' order by score desc;

-- 统计物理科目的最高分，最低分，平均分
select
    subject,
    max(score) as max_score,
    min(score) as min_score,
    avg(score) as avg_score
from student_scores where subject='物理';

-- 统计各班级人数
select
    class,
    count(1) as cnt
from school_db.student_scores group by class;

-- 统计各科目平均分
select
    subject,
    avg(score) as avg
from student_scores group by subject;

-- 统计各班各科目最高分
select
    class,
    subject,
    max(score) as max_score
from student_scores group by class, subject;

-- 统计所有女生平均分超过 90 分的科目
select
    subject,
    avg(score) as avg_score
from student_scores where gender='女' group by subject having avg_score > 90;
```

## Join

```sql
select * from <left_table> inner|left|right join <right_table> on <condition>...
```

连接会将多个表按笛卡尔积拼接在一起，然后根据条件过滤得到数据项并返回指定列。

```language
table A      table B
| 1 | a |    | c | 3 |
| 2 | b |    | d | 4 |

table A x table B
| 1 | a | c | 3 |
| 1 | a | d | 4 |
| 2 | b | c | 3 |
| 2 | b | d | 4 |
```

- 内连接：两张表的交集
- 左外连接：两张表的交集，左表满足条件的部分也会出现，右表部分会填充 NULL
- 右外连接：两张表的交集，右表满足条件的部分也会出现，左表部分会填充 NULL

多个连接会按顺序从笛卡尔积表中过滤。

# clickhousenotes
clickhouse 相关笔记以及经验


### 1. clickhouse client
* 建议使用clickhouse http interface, 其自由度更高，但是需要自己对数据做一定的预处理；
* insert数据时建议使用values或者JSONEachRow格式，批量插入(每批1000条，平均每条2k)时values格式耗时0.04s，JSONEachRow格式耗时0.06s；
* insert时采用values格式插入需要提前对数据做[转义](https://dev.mysql.com/doc/refman/8.0/en/string-literals.html)，可以参考[escape.py](escape.py)中方法

### 2. 插入性能
* insert数据时建议使用values或者JSONEachRow格式，批量插入(每批1000条，平均每条2k)时values格式耗时0.04s，JSONEachRow格式耗时0.06s；
* insert批量插入(每批1000条，平均每条2k)到非Replicated本地表时耗时0.04s，插入到Replicated本地表时耗时0.3s；插入Replicated表时需要有ZK相关协调等

### 3. 系统表统计数据查询
* 参见 [stat.sql](stat.sql)

### 4. 删除分布式复制表时遇到的问题
问题：创建分布式复制表时由于字段命名错误等想通过删除表后重建新表，在删除旧表后，如果立即新建新表提示ZK中相关路径已经存在无法新建

~~临时方法：等待一定时间等clickhouse将zk中表相关元数据等删除后在创建，等待时间未知~~
~~尝试过：手动将zk中数据删除，结果导致clickhouse异常~~

解决方法：

1、建表时指定使用不同的zk路径 

2、drop table no delay | sync

3、调低 database_atomic_wait_for_drop_and_detach_synchronously 

参考 [clickhouse-issues-20243](https://github.com/ClickHouse/ClickHouse/issues/20243)

~~~dbmysql
DROP TABLE table_name ON cluster cluster_name
~~~

### 5. 删除分区
查找分区
~~~dbmysql
SELECT distinct(partition) 
FROM system.parts 
WHERE database='target_database' and table = 'target_table';

ALTER TABLE 'target_table' ON CLUSTER 'cluster_name' DROP PARTITION 'partition_name'
~~~

### 6. 查看所有集群信息
~~~dbmysql
SELECT * FROM system.clusters FORMAT Vertical;
~~~

### 7. 修改order by
已存在如果要修改order by则无法添加已存在字段 必须是在alter中add column的新列；

给大表修改order by，可以先将数据导出到本地，然后删表、重新创建表，在把数据导入到表中；

方法一 导入导出：
~~~shell
# export 默认格式为 TabSeparated；可以通过FORMAT 指定
clickhouse-client --port port -d database_name -q "select * from table_name " > xxx

# import
clickhouse-client --port port -d database_name -q "insert into table_name FORMAT TabSeparated" < xxx
~~~

方法二 insert select 【未尝试 估计server压力大 不适合大表】：
~~~shell
insert into table_name select * from table_name2
~~~
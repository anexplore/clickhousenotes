/*
查看系统相关状态
*/

/*整个系统空间的磁盘占用比例*/
SELECT
    sum(rows) AS `行数`,
    formatReadableSize(sum(data_uncompressed_bytes)) AS `原始大小`,
    formatReadableSize(sum(data_compressed_bytes)) AS `压缩大小`,
    round((sum(data_compressed_bytes) / sum(data_uncompressed_bytes)) * 100, 0) AS `压缩百分比`
FROM system.parts


/*查看每张表的大小以及压缩比例*/
SELECT
    table AS `表名`,
    sum(rows) AS `行数`,
    formatReadableSize(sum(data_uncompressed_bytes)) AS `原始大小`,
    formatReadableSize(sum(data_compressed_bytes)) AS `压缩大小`,
    round((sum(data_compressed_bytes) / sum(data_uncompressed_bytes)) * 100, 0) AS `压缩百分比`
FROM system.parts
GROUP BY table


/*查看所有分区大小以及比例*/
SELECT
    partition AS `分区`,
    sum(rows) AS `行数`,
    formatReadableSize(sum(data_uncompressed_bytes)) AS `原始大小`,
    formatReadableSize(sum(data_compressed_bytes)) AS `压缩大小`,
    round((sum(data_compressed_bytes) / sum(data_uncompressed_bytes)) * 100, 0) AS `压缩百分比`
FROM system.parts
WHERE table = 'target_table' and database = 'target_database'
GROUP BY partition
ORDER BY partition ASC


/*查看指定表字段占用大小*/

SELECT
    column AS `字段名`,
    any(type) AS `类型`,
    formatReadableSize(sum(column_data_uncompressed_bytes)) AS `原始大小`,
    formatReadableSize(sum(column_data_compressed_bytes)) AS `压缩大小`,
    sum(rows) AS `行数`
FROM system.parts_columns
WHERE table = 'target_table' and database = 'target_database'
GROUP BY column
ORDER BY column ASC
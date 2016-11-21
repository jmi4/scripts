#!/usr/bin/env ruby
# Refer to: http://dba.stackexchange.com/questions/155792/performance-tuning-large-mysql-databases-for-zabbix

# Get needed values for equations:
key_reads = `mysql -BNe "SHOW STATUS LIKE 'key_reads';" |awk '{print $2}'`.chomp.to_f
key_read_requests = `mysql -BNe "SHOW STATUS LIKE 'key_read_requests';" |awk '{print $2}'`.chomp.to_f
Binlog_cache_disk_use = `mysql -BNe "SHOW STATUS LIKE 'Binlog_cache_disk_use';" |awk '{print $2}'`.chomp.to_i
mysql_uptime = `mysql -BNe "SHOW STATUS LIKE 'uptime';" |awk '{print $2}'`.chomp.to_i
innodb_buffer_pool_reads = `mysql -BNe "SHOW STATUS LIKE 'Innodb_buffer_pool_reads';" |awk '{print $2}'`.chomp.to_i
innodb_buffer_pool_pages_flushed = `mysql -BNe "SHOW STATUS LIKE 'Innodb_buffer_pool_pages_flushed';" |awk '{print $2}'`.chomp.to_i
created_tmp_tables = `mysql -BNe "SHOW GLOBAL STATUS LIKE 'created_tmp_tables';" |awk '{print $2}'`.chomp.to_i
created_tmp_disk_tables = `mysql -BNe "SHOW GLOBAL STATUS LIKE 'created_tmp_disk_tables';" |awk '{print $2}'`.chomp.to_i
select_scan = `mysql -BNe "SHOW GLOBAL STATUS LIKE 'Select_scan';" |awk '{print $2}'`.chomp.to_i

# Gather needed calculations
key_cache_hit_percentage = "#{(1 - (key_reads / key_read_requests)) * 100}".to_f.round
innodb_pool_io_ps = "#{(innodb_buffer_pool_reads + innodb_buffer_pool_pages_flushed) / mysql_uptime }".to_f.round
created_tmp_tables_ps = "#{created_tmp_tables / mysql_uptime }".to_f.round
created_tmp_disk_tables_ps = "#{created_tmp_disk_tables / mysql_uptime }".to_f.round
select_scan_ps = "#{select_scan / mysql_uptime }".to_f.round

# Output data to user.
puts "-------- Performance Tuning ---------------------------------------------------------------------------"
case
when key_cache_hit_percentage > 89
  puts "[\033[0;32mOK\033[0m] key_cache_hit_percentage is #{key_cache_hit_percentage}% and does not need adjusted"
when key_cache_hit_percentage < 90
  puts "[\033[0;31m!!\033[0m] key_cache_hit_percentage is #{key_cache_hit_percentage}% and should be increased"
end

case
when Binlog_cache_disk_use > 0
  puts "[\033[0;31m!!\033[0m] Binlog_cache_disk_use is #{Binlog_cache_disk_use} and needs to be increased to allow transactions to enter cache"
when Binlog_cache_disk_use == 0
  puts "[\033[0;32mOK\033[0m] Binlog_cache_disk_use is #{Binlog_cache_disk_use} which is ideal, no change is needed."
end
puts "-------- Stats I am not sure what to do with yet  ------------------------------------------------------"

puts "InnoDB Pool IO: #{innodb_pool_io_ps}/sec"
puts "Created_tmp_tables: #{created_tmp_tables_ps}/sec"
puts "created_tmp_disk_tables: #{created_tmp_disk_tables_ps}/sec"
puts "Full table scans: #{select_scan_ps}/sec"

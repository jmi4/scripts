#!/usr/bin/env ruby
# Refer to: http://dba.stackexchange.com/questions/155792/performance-tuning-large-mysql-databases-for-zabbix

# Get needed values for equations:
mysql_gid = `cat /etc/group |grep ^mysql: |awk -F: '{print $3}'`
key_reads = `mysql -BNe "SHOW STATUS LIKE 'key_reads';" |awk '{print $2}'`.chomp.to_f
key_read_requests = `mysql -BNe "SHOW STATUS LIKE 'key_read_requests';" |awk '{print $2}'`.chomp.to_f
Binlog_cache_disk_use = `mysql -BNe "SHOW STATUS LIKE 'Binlog_cache_disk_use';" |awk '{print $2}'`.chomp.to_i
mysql_uptime = `mysql -BNe "SHOW STATUS LIKE 'uptime';" |awk '{print $2}'`.chomp.to_i
innodb_buffer_pool_reads = `mysql -BNe "SHOW STATUS LIKE 'Innodb_buffer_pool_reads';" |awk '{print $2}'`.chomp.to_i
innodb_buffer_pool_pages_flushed = `mysql -BNe "SHOW STATUS LIKE 'Innodb_buffer_pool_pages_flushed';" |awk '{print $2}'`.chomp.to_i
created_tmp_tables = `mysql -BNe "SHOW GLOBAL STATUS LIKE 'created_tmp_tables';" |awk '{print $2}'`.chomp.to_i
created_tmp_disk_tables = `mysql -BNe "SHOW GLOBAL STATUS LIKE 'created_tmp_disk_tables';" |awk '{print $2}'`.chomp.to_i
select_scan = `mysql -BNe "SHOW GLOBAL STATUS LIKE 'Select_scan';" |awk '{print $2}'`.chomp.to_i
innodb_rows_inserted = `mysql -BNe "show status like 'Innodb_rows_inserted';" |awk '{print $2}'`.chomp.to_i
query_cache_size = `mysql -BNe "show variables like 'query_cache_size';" |awk '{print $2}'`.chomp.to_i
table_open_cache = `mysql -BNe "show variables like 'table_open_cache';" |awk '{print $2}'`.chomp.to_i
innodb_log_file_size = `mysql -BNe "show variables like 'innodb_log_file_size';" |awk '{print $2}'`.chomp.to_i
innodb_buffer_pool_instances = `mysql -BNe "show variables like 'innodb_buffer_pool_instances';" |awk '{print $2}'`.chomp.to_i
innodb_buffer_pool_size = `mysql -BNe "show variables like 'innodb_buffer_pool_size';" |awk '{print $2}'`.chomp.to_i



# Gather needed calculations
key_cache_hit_percentage = "#{(1 - (key_reads / key_read_requests)) * 100}".to_f.round
innodb_pool_io_ps = "#{(innodb_buffer_pool_reads + innodb_buffer_pool_pages_flushed) / mysql_uptime }".to_f.round
created_tmp_tables_ps = "#{created_tmp_tables / mysql_uptime }".to_f.round
created_tmp_disk_tables_ps = "#{created_tmp_disk_tables / mysql_uptime }".to_f.round
select_scan_ps = "#{select_scan / mysql_uptime }".to_f.round
innodb_rows_inserted_ps = "#{innodb_rows_inserted / mysql_uptime }".to_f.round
s_var = "#{(query_cache_size + table_open_cache + innodb_buffer_pool_size + innodb_log_file_size) * 1.1}".to_f.round
vm_nr_hugepages = "#{s_var / 1024 /2048}".to_f.round
kernel_shmall = "#{s_var / 4096}".to_f.round
kernel_shmmax = "#{innodb_buffer_pool_size / innodb_buffer_pool_instances}".to_f.round

# Output data to user.
puts ''
puts "-------- Performance Tuning ---------------------------------------------------------------------------"
puts ""
# http://www.ewhathow.com/2013/09/what-is-the-recommended-value-of-key_buffer_size-in-mysql/
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
puts ""
puts "-------- Stats I am not sure what to do with yet  ------------------------------------------------------"
puts ""
puts "InnoDB Pool IO: #{innodb_pool_io_ps}/sec"
puts "Created_tmp_tables: #{created_tmp_tables_ps}/sec"
puts "created_tmp_disk_tables: #{created_tmp_disk_tables_ps}/sec"
puts "Full table scans: #{select_scan_ps}/sec"
puts "Rows inserted: #{innodb_rows_inserted_ps}/sec"
puts ""
puts "-------- How to setup huge pages with current settings  -------------------------------------------------"
# https://www.linkedin.com/pulse/configuring-huge-pages-mysql-server-red-hat-linux-juan-soto
puts ""
puts "Set these setting in /etc/sysctl.cnf"
puts "Set vm.nr_hugepages to: #{vm_nr_hugepages}"
puts "Set kernel.shmall to: #{kernel_shmall}"
puts "Set kernel.shmmax to: #{kernel_shmmax}"
puts "Set vm.hugetlb_shm_group to: #{mysql_gid}"
puts 'Add "large-pages" to your /etc/my.cnf file'
puts 'Reboot the server'
puts ""

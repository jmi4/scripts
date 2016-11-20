#!/usr/bin/env ruby
# WIP
# Using to determine some memory configuration optimizations for mysql.

# Get needed values for equations:
key_reads = `mysql -BNe "SHOW STATUS LIKE 'key_reads';" |awk '{print $2}'`.chomp.to_f
key_read_requests = `mysql -BNe "SHOW STATUS LIKE 'key_read_requests';" |awk '{print $2}'`.chomp.to_f

# Gather needed calculations
key_cache_hit_percentage = "#{(1 - (key_reads / key_read_requests)) * 100}".to_f.round

# Output data to user.

case
when key_cache_hit_percentage > 89
  puts "key_cache_hit_percentage is #{key_cache_hit_percentage}% and does not need adjusted"
when key_cache_hit_percentage < 90
  puts "key_cache_hit_percentage is #{key_cache_hit_percentage}% and should be increased"
end

puts key_cache_hit_percentage

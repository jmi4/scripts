#!/usr/bin/env ruby
# Usage:
# ./script.rb <dbname>
dbname = ARGV[0]

tables = `mysql -BNe "show tables from #{dbname};"`
tables.each do |tbl|
  show = `mysql -BNe "show create table #{dbname}.#{tbl}\\G"`
  puts show
end

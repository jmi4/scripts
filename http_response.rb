#!/usr/bin/env ruby
require 'optparse'
require 'benchmark'
include Benchmark

options = { advanced: nil, site: nil, time: nil }
parser = OptionParser.new do |opts|
  opts.banner = 'Usage: http_response.rb [options]'
  opts.on('-a', '--advanced', 'Enables more statistics') do |advanced|
    options[:advanced] = advanced
  end

  opts.on('-s SITENAME', '--site SITENAME', 'Ex: http://google.com') do |site|
    options[:site] = site
  end

  opts.on('-t TIME', '--time TIME', 'Ex: 300 (in seconds)') do |time|
    options[:time] = time
  end

  opts.on('-h', '--help', 'Displays Help') do
    puts opts
    exit
  end
end
parser.parse!

raise('The site argument is required: -s <site>') if options[:site].nil?

time = if options[:time].nil?
         5
       else
         options[:time]
       end

unless options[:advanced]
  total = 0
  i = 0
  stop_time = Time.now.to_i + time.to_i
  while Time.now.to_i < stop_time
    Benchmark.benchmark(CAPTION, 30, FORMAT, '>total:', '>avg:') do |x|
      tt = x.report(Time.now.strftime('%Y%m%d %H%M%S.%3N')) { `curl -s -o /dev/null #{options[:site]}` }
      i += 1
      total = tt + total
      [total, total / i]
    end
    sleep 1
  end
end

# Advanced
if options[:advanced]
  p = 0
  count = 0
  times_f = []
  stop_time = Time.now.to_i + time.to_i
  printf("%-23s%-20s%-20s%-20s%-20s%-20s%-20s%-20s\n", 'Time', 'time_namelookup', 'time_connect', 'time_appconnect', 'time_redirect', 'time_pretransfer', 'time_starttransfer', 'time_total')
  while Time.now.to_i < stop_time
    p += 1
    count += 1
    times = `curl -o /dev/null -s -A "Mozilla/4.0"  -w '%{time_namelookup} %{time_connect} %{time_appconnect} %{time_redirect} %{time_pretransfer} %{time_starttransfer} %{time_total}' http://www.google.com`.split
    printf("%-23s%-20s%-20s%-20s%-20s%-20s%-20s%-20s\n", Time.now.strftime('%Y%m%d %H%M%S.%3N'), times[0], times[1], times[2], times[3], times[4], times[5], times[6])
    if p > 28
      printf("%-23s%-20s%-20s%-20s%-20s%-20s%-20s%-20s\n", 'Time', 'time_namelookup', 'time_connect', 'time_appconnect', 'time_redirect', 'time_pretransfer', 'time_starttransfer', 'time_total')
      p = 0
    end
    sleep 1
    times_f << times.map(&:to_f)
  end
  tot_time_namelookup = times_f.map { |e| e[0] }.reduce(:+).round(3)
  tot_time_connect = times_f.map { |e| e[1] }.reduce(:+).round(3)
  tot_time_appconnect = times_f.map { |e| e[2] }.reduce(:+).round(3)
  tot_time_redirect = times_f.map { |e| e[3] }.reduce(:+).round(3)
  tot_time_pretransfer = times_f.map { |e| e[4] }.reduce(:+).round(3)
  tot_time_starttransfer = times_f.map { |e| e[5] }.reduce(:+).round(3)
  tot_time_total = times_f.map { |e| e[6] }.reduce(:+).round(3)

  max_time_namelookup = times_f.map { |e| e[0] }.max.round(3)
  max_time_connect = times_f.map { |e| e[1] }.max.round(3)
  max_time_appconnect = times_f.map { |e| e[2] }.max.round(3)
  max_time_redirect = times_f.map { |e| e[3] }.max.round(3)
  max_time_pretransfer = times_f.map { |e| e[4] }.max.round(3)
  max_time_starttransfer = times_f.map { |e| e[5] }.max.round(3)
  max_time_total = times_f.map { |e| e[6] }.max.round(3)

  avg_time_namelookup = times_f.map { |e| e[0] }.reduce(:+).round(3) / count
  avg_time_connect = times_f.map { |e| e[1] }.reduce(:+).round(3) / count
  avg_time_appconnect = times_f.map { |e| e[2] }.reduce(:+).round(3) / count
  avg_time_redirect = times_f.map { |e| e[3] }.reduce(:+).round(3) / count
  avg_time_pretransfer = times_f.map { |e| e[4] }.reduce(:+).round(3) / count
  avg_time_starttransfer = times_f.map { |e| e[5] }.reduce(:+).round(3) / count
  avg_time_total = times_f.map { |e| e[6] }.reduce(:+).round(3) / count

  puts
  printf("%-23s%-20s%-20s%-20s%-20s%-20s%-20s%-20s\n", 'Statistic', 'time_namelookup', 'time_connect', 'time_appconnect', 'time_redirect', 'time_pretransfer', 'time_starttransfer', 'time_total')
  printf("%-23s%-20.3f%-20.3f%-20.3f%-20.3f%-20.3f%-20.3f%-20.3f\n", 'Avg', avg_time_namelookup, avg_time_connect, avg_time_appconnect, avg_time_redirect, avg_time_pretransfer, avg_time_starttransfer, avg_time_total)
  printf("%-23s%-20.3f%-20.3f%-20.3f%-20.3f%-20.3f%-20.3f%-20.3f\n", 'Max', max_time_namelookup, max_time_connect, max_time_appconnect, max_time_redirect, max_time_pretransfer, max_time_starttransfer, max_time_total)
  printf("%-23s%-20.3f%-20.3f%-20.3f%-20.3f%-20.3f%-20.3f%-20.3f\n", 'Total', tot_time_namelookup, tot_time_connect, tot_time_appconnect, tot_time_redirect, tot_time_pretransfer, tot_time_starttransfer, tot_time_total)
end

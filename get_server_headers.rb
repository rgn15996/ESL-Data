require 'csv'
require 'rubygems'
require "#{File.dirname(__FILE__)}/esldata"

count = 0
srvs = Array.new


ESLdata.load_servers(srvs)

ESLdata.del_deinstalled(srvs)

srvs[0].each do |key,value|
  puts "#{key}"
end


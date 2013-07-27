require 'csv'
require 'rubygems'
require 'json'
require "#{File.dirname(__FILE__)}/esldata"

count = 0
srvs = Array.new
hash = Hash.new

puts "Loading Server data"
ESLdata.load_servers(srvs)

puts "\nremoving deinstalled...\n"
ESLdata.del_deinstalled(srvs)

puts "Loaded #{srvs.length} nodes from server data"

srvs.each do |srv|
  srv.each do |key, value|
    puts "key is #{key} : value is #{value}"
  end
end

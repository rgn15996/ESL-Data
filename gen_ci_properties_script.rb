require 'csv'
require 'rubygems'
require 'json'
require "#{File.dirname(__FILE__)}/esldata"

count = 0
srvs = Array.new
hash = Hash.new

# puts "Loading Server data"
ESLdata.load_servers(srvs)

# puts "\nremoving deinstalled...\n"
ESLdata.del_deinstalled(srvs)

srvs.each_slice(100) do |sys_batch|
  cypher_query = { :statements => []}
  index = 0
  stuff = "begin \n"
  sys_batch.each do |sys|
    index += 1
    
    query = ESLdata.CQLsetProperties(sys, index) + "\n"
    stuff += query
  end
  stuff += "\ncommit\nexit\n"
  
  puts stuff
end


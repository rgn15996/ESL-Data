require 'csv'
require 'rubygems'
require "#{File.dirname(__FILE__)}/esldata"

count = 0
srvs = Array.new


ESLdata.load_servers(srvs)

ESLdata.del_deinstalled(srvs)

srvs.each_slice(100) do |sys_batch|
  cypher_query = { :statements => []}
  index = 0
  stuff = "begin \n"
  # stuff = ""
  sys_batch.each do |sys|
    index += 1
    
    query = ESLdata.CQLCreate(sys, index) + "\n"
    stuff += query
    #stuff += "CREATE (n#{index}:thingy {name : 'thing#{index}'}) "
  end
  stuff += ";\ncommit\nexit\n"
  
  puts stuff
end


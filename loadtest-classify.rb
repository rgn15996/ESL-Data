require 'csv'
require 'rubygems'
require 'neography'
require "#{File.dirname(__FILE__)}/esldata"

count = 0
srvs = Array.new

puts "Loading Server data"
ESLdata.load_servers(srvs)

puts "\nremoving deinstalled...\n"
ESLdata.del_deinstalled(srvs)

puts "Loaded #{srvs.length} nodes from server data"

@neo = Neography::Rest.new
# System types?
funny_types = 0
srvs.each_slice(200) do |sys_batch|
  query = ""
  index = 0
  sys_batch.each do |sys|
    index += 1
    type = ESLdata.classify_server(sys)
    if type == "Unknown" then
      funny_types += 1
    end
    query += ESLdata.constructQuery(sys, type, index) #"CREATE (n#{index}:#{type} { name : '#{sys[:full_node_name]}'}) "    
  end
  batch_result  = @neo.execute_query(query)
  print "."
end
print "There are still #{funny_types} funny nodes"

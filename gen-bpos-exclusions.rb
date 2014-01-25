require 'csv'
require 'rubygems'
require "#{File.dirname(__FILE__)}/esldata"

items = Array.new
names = Array.new

ESLdata.load_BPOS_exclusions(items)

# puts "BPOS Exclusions " + items.length.to_s
puts 'MERGE (n:list {name: "Billing Exclusions"});'


items.each_slice(100) do |item_batch|
  puts "begin"

  item_batch.each do |item|

    config_item = item[:full_nodename]
    names << config_item

    query  = "MATCH (x), (y) " 
    query += "WHERE x.full_node_name =~ '^#{config_item}.*' "
    query += "AND y.name = 'Billing Exclusions' "
    query += "MERGE (x)-[r:IS_MEMBER_OF]->(y) "
    query += "SET r.reason='BPOS' "
    query += "RETURN x.full_node_name;"

    puts query
  end
  puts "commit\nexit"

  puts "length is " + names.uniq.length.to_s
end


  
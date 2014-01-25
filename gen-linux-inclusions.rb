require 'csv'
require 'rubygems'
require "#{File.dirname(__FILE__)}/esldata"

items = Array.new
reasons = Array.new

ESLdata.load_LINUX_inclusions(items)

# items[0].each do |key,value|
#   puts "#{key}"
# end

# puts "Linux corrected " + items.length.to_s


items.each_slice(100) do |item_batch|
  # puts "begin"

  item_batch.each do |item|

    config_item = item[:ci]
    node = item[:full_nodename]

    query  = "MATCH (x)-[r:IS_MEMBER_OF]-(l:list) "
    query += "WHERE x.full_node_name = '#{node}' "
    query += "AND l.name = 'Billing Exclusions' "
    query += "DELETE r "
    query += "RETURN x.full_node_name;"

    puts query
  
    # if exclude == true then
    #   # puts "#{config_item} excluded for " + reasons.to_s
    #   query  = "MATCH (x), (y) " 
    #   query += "WHERE x.full_node_name =~ '^#{config_item}.*' "
    #   query += "AND y.name = 'Billing Exclusions' "
    #   query += "MERGE (x)-[r:IS_MEMBER_OF]->(y) "
    #   query += "SET r.reason='#{reasons.to_s}' "
    #   query += "RETURN x.full_node_name;"
  
    #   puts query
    # end

   
  end
  # puts "commit\nexit"
end


  
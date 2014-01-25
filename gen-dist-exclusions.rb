require 'csv'
require 'rubygems'
require "#{File.dirname(__FILE__)}/esldata"

items = Array.new
reasons = Array.new

ESLdata.load_DIST(items)

# items[0].each do |key,value|
#   puts "#{key}"
# end

# puts "DIST corrected " + items.length.to_s
puts 'MERGE (n:list {name: "Billing Exclusions"});'


items.each_slice(100) do |item_batch|
  # puts "begin"

  item_batch.each do |item|

    config_item = item[:configuration_item]

    reasons.clear
    exclude = false

    if item[:survives_unknown_hsn_excl] == "0" then
      exclude = true
      reasons << "Unknown HSN"
    end
    if item[:survives_inbuild_excl] == "0" then
      exclude = true
      reasons << "In build"
    end
    if item[:survives_combined_exclusion_list] == "0" then
      exclude = true
      reasons << "Combined List"
    end
    if item[:survives_system_overhead] == "0" then
      exclude = true
      reasons << "System Overhead"
    end
    if item[:survives_dual_running_list] == "0" then 
      exclude = true
      reasons << "Dual running"
    end

    if exclude == true then
      # puts "#{config_item} excluded for " + reasons.to_s
      query  = "MATCH (x), (y) " 
      query += "WHERE x.full_node_name =~ '^#{config_item}.*' "
      query += "AND y.name = 'Billing Exclusions' "
      query += "MERGE (x)-[r:IS_MEMBER_OF]->(y) "
      query += "SET r.reason='#{reasons.to_s}' "
      query += "RETURN x.full_node_name;"
  
      puts query
    end

   
  end
  # puts "commit\nexit"

  # puts "length is " + names.uniq.length.to_s
end


  
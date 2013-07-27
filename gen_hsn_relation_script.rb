require 'csv'
require 'rubygems'

require "#{File.dirname(__FILE__)}/esldata"

hsns = Array.new
chash = Hash.new


ESLdata.load_hsns(hsns)


hsns.each_slice(100) do |hsn_batch|
  
  query = "begin\n"
  hsn_batch.each do |hsn|

    ci = ""
    hsn_name = ""
    ci = hsn[:full_node_name] 
    hsn_name = hsn[:solution_name]

    query += "MATCH n " +
             "WHERE has(n.full_node_name) " +
             "AND n.full_node_name = '#{ci}' " +
             "CREATE UNIQUE n-[r:IS_COMPONENT_OF]->(m:hsn {name:'#{hsn_name}'}) " +
             "RETURN m,r;\n" 
  end
  query += "commit\nexit\n"
  puts query
end


  
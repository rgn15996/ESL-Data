require 'csv'
require 'rubygems'

require "#{File.dirname(__FILE__)}/esldata"

hsns = Array.new
chash = Hash.new


ESLdata.load_hsns(hsns)


hsns.each_slice(200) do |hsn_batch|
  
  query = "begin\n"

  hsn_batch.each do |hsn|

    ci = hsn[:full_node_name] 
    hsn_name = hsn[:solution_name]

    query += "MATCH n,m " +
             "WHERE n.full_node_name! = '#{ci}' " +
             "AND m.name! = '#{hsn_name}' " +
             "CREATE UNIQUE n-[r:IS_COMPONENT_OF]->m;\n "
  #           "RETURN ID(m),ID(n);\n" 
  end
  query += "commit\nexit\n"
  puts query
end


  
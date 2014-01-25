require 'csv'
require 'rubygems'
require "#{File.dirname(__FILE__)}/esldata"

rels = Array.new

ESLdata.load_relations(rels)

rels.each_slice(100) do |rel_batch|
  puts "begin"

  rel_batch.each do |rel|

    child = ""
    parent = ""
    child = rel[:full_node_name] 
    parent = rel[:parent_system]
    query = "MATCH n, m " +
            "WHERE n.full_node_name = '#{child}' AND m.full_node_name = '#{parent}' "
    case rel[:relation_type]
    when "Mainframe", "Farm", "Farm for Virtual Guest", "Farm for Logical Server"
      relation = "IS_HOSTED_ON"
    when "Cluster"
      relation = "IS_MEMBER_OF"
    when "Cabinet"
      relation = "IS_LOCATED_IN"
    when "Storage Array"
      relation = "IS_HOSTED_ON"
    else
      relation = "DEPENDS_ON"
    end

    query += "CREATE UNIQUE n-[r:#{relation}]->m;\n"
    puts query
  end
  puts "commit\nexit"
end


  
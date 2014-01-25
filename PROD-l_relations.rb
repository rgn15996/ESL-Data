require 'csv'
require 'rubygems'
require 'neography'
require "#{File.dirname(__FILE__)}/esldata"

rels = Array.new
@neo = Neography::Rest.new

ESLdata.load_relations(rels)

rels.each_slice(100) do |rel_batch|
  #tx = @neo.begin_transaction

  rel_batch.each do |rel|

    child = rel[:full_node_name] 
    parent = rel[:parent_system]
    query_string = "MATCH n, m " +
            "WHERE n.full_node_name = '#{child}' AND m.full_node_name = '#{parent}' "
    case rel[:relation_type]
    when "Mainframe", "Farm", "Farm for Virtual Guest", "Farm for Logical Server"
      relation = "IS_HOSTED_ON"
    when "Cluster"
      relation = "IS_MEMBER_OF"
    when "Cabinet"
      relation = "IS_LOCATED_IN"
    else
      relation = "DEPENDS_ON"
    end

    query_string += "CREATE UNIQUE n-[r:#{relation}]->m RETURN r;\n"
    #@neo.in_transaction(tx, query_string)
    # puts query_string
    @neo.execute_query(query_string)
  end
  #@neo.commit_transaction(tx)
  print "."
end


  
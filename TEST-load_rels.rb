require 'csv'
require 'rubygems'
require 'neography'
require 'rest_client'
require "#{File.dirname(__FILE__)}/esldata"

BASE_URL = 'http://localhost:7474/db/data'

rels = Array.new
chash = Hash.new


ESLdata.load_relations(rels)

rels.each_slice(100) do |rel_batch|
  batch_query = { :statements => []}
  
  rel_batch.each do |rel|

    child = rel[:full_node_name] 
    parent = rel[:parent_system]
    chash[:statement] = "MATCH n, m " +
                        "WHERE n.full_node_name! = '#{child}' " + 
                        "AND m.full_node_name! = '#{parent}' "
    case rel[:relation_type]
    when "Mainframe", "Farm", "Farm for Virtual Guest", "Farm for Logical Server"
      relation = "IS_HOSTED_ON"
    when "Cluster"
      relation = "IS_MEMBER_OF"
    when "Cabinet"
      relation = "IS_LOCATED_IN"
    end

    chash[:statement] += "CREATE UNIQUE n-[r:#{relation}]->m RETURN r;\n"
    batch_query[:statements] << chash.clone
    chash.clear
  end
  response = ESLdata.open_transaction()
  if response.code == 201 then
    url = response.headers[:location].to_s
    res = ESLdata.transact_query(url, batch_query.to_json)
    commit_url = JSON.parse(res)["commit"]
    res2 = ESLdata.commit_transaction(commit_url)
    print "."
  end
end

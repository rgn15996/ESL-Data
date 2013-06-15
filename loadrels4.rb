require 'csv'
require 'rubygems'
require 'neography'
require 'rest_client'
require "#{File.dirname(__FILE__)}/esldata"

BASE_URL = 'http://localhost:7474/db/data'

def find_entity(entity_label, property, value)
  neo = Neography::Rest.new
  cypher_query = "MATCH n:#{entity_label} WHERE n.#{property}='#{value}' "
  cypher_query << "RETURN n.name"
  puts cypher_query
  neo.execute_query(cypher_query)["data"]
end


rels = Array.new
chash = Hash.new


ESLdata.load_relations(rels)

#puts find_entity("PowerVM_guest", "name", "*")

# cquery[:query] = "MATCH n:PowerVM_guest RETURN ID(n),n.name;"
# cquery[:params] = params
# puts cquery.to_json
# puts JSON.parse(ESLdata.cypher_query(cquery.to_json))

rels.each_slice(100) do |rel_batch|
  batch_query = { :statements => []}
  
  rel_batch.each do |rel|

    child = ""
    parent = ""
    child = rel[:full_node_name] 
    parent = rel[:parent_system]
    chash[:statement] = "MATCH n:PowerVM_guest, m:PowerVM_host" +
      " WHERE n.name = '#{child}' AND m.name = '#{parent}' " +
      "CREATE UNIQUE n-[r:IS_HOSTED_ON]->m RETURN r;"
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


  #puts cypher_query.to_json

  
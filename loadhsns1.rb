require 'csv'
require 'rubygems'
require 'neography'
require 'rest_client'
require "#{File.dirname(__FILE__)}/esldata"

BASE_URL = 'http://localhost:7474/db/data'

hsns = Array.new
chash = Hash.new


ESLdata.load_hsns(hsns)


hsns.each_slice(100) do |hsn_batch|
  batch_query = { :statements => []}
  
  hsn_batch.each do |hsn|

    ci = ""
    hsn_name = ""
    ci = hsn[:full_node_name] 
    hsn_name = hsn[:solution_name]

    chash[:statement] = "MATCH n " +
                        "WHERE n.name = '#{ci}' " +
                        "CREATE UNIQUE n-[r:IS_COMPONENT_OF]->(m:hsn {name:'#{hsn_name}'}) " +
                        "RETURN m,r;" 
    # chash[:statement] = "MATCH n:PowerVM_guest, m:PowerVM_host" +
    #   " WHERE n.name = '#{child}' AND m.name = '#{parent}' " +
    #   "CREATE UNIQUE n-[r:IS_HOSTED_ON]->m RETURN r;"
    batch_query[:statements] << chash.clone
    chash.clear
  end
  response = ESLdata.open_transaction()
  if response.code == 201 then
    url = response.headers[:location].to_s
    puts url
    puts batch_query.to_json
    res = ESLdata.transact_query(url, batch_query.to_json)
    commit_url = JSON.parse(res)["commit"]
    puts commit_url
    res2 = ESLdata.commit_transaction(commit_url)
    print "."
  end
end

#puts cypher_query.to_json

  
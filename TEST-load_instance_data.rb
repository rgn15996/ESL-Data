require 'csv'
require 'rubygems'
require 'neography'
require 'rest_client'
require "#{File.dirname(__FILE__)}/esldata"

BASE_URL = 'http://localhost:7474/db/data'

insts = Array.new
chash = Hash.new


ESLdata.load_instances(insts)

insts.each_slice(100) do |inst_batch|
  batch_query = { :statements => []}
  
  inst_batch.each do |inst|

    hsn = inst[:solution_name]
    sys = inst[:instance_system_name]
    sol = inst[:instance_solution_name]
    appInst = inst[:instance_name]

    chash[:statement] = "MATCH n:server, m:hsn " +
                        "WHERE n.full_node_name! ='#{sys}' " +
                        "AND m.name! ='#{hsn}' " +
                        "CREATE UNIQUE n-[:IS_COMPONENT_OF]->m " +
                        "RETURN; "
    chash[:statement] += "MATCH sys:server " +
                         "WHERE sys.full_node_name! = '#{sys}' " +
                         "CREATE UNIQUE n:appInst-[r:IS_HOSTED_ON]->sys " +
                         "SET n.name = '#{appInst}"
                         "RETURN;"

   

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

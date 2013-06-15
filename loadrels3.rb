require 'csv'
require 'rubygems'
require 'neography'
require 'rest_client'
require "#{File.dirname(__FILE__)}/esldata"

rels = Array.new
cquery = Hash.new
params = Hash.new

ESLdata.load_relations(rels)


rels.each_with_index do |rel, i|
  child = ""
  parent = ""
  child = rel[:full_node_name] 
  parent = rel[:parent_system]
  # querystring = "MATCH n, m " +
  #   "WHERE (n:PowerVM_guest OR n:VMWare_guest) AND " + 
  #   "(m:PowerVM_host OR m:VMWare_host) AND n.name = '#{child}' AND m.name = '#{parent}' " +
  #   "CREATE UNIQUE n-[r:IS_HOSTED_ON]->m " +
  #   "RETURN r;"
  querystring = "MATCH n:PowerVM_guest, m:PowerVM_host WHERE n.name = '#{child}' AND m.name = '#{parent}' " +
    "CREATE UNIQUE n-[r:IS_HOSTED_ON]->m RETURN r;"
  # cquery[:query] = querystring
  # cquery[:params] = params
  # puts cquery.to_json
  # puts ESLdata.cypher_query(cquery.to_json)
  puts querystring
end

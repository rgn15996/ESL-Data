require 'csv'
require 'rubygems'
require 'neography'
require "#{File.dirname(__FILE__)}/esldata"

def find_vm(node)
  neo = Neography::Rest.new
  cypher_query =  "START node = node:vm(name='#{node}')"
  cypher_query << "RETURN ID(node)"
  neo.execute_query(cypher_query)["data"]
end

def find_vmhost(node)
  neo = Neography::Rest.new
  cypher_query =  "START node = node:vmhost(name='#{node}')"
  cypher_query << "RETURN ID(node)"
  neo.execute_query(cypher_query)["data"]
end

rels = Array.new

Esldata.load_relations(rels)

#@neo = Neography::Rest.new

rels.each_with_index do |rel, i|
  if rel[:relation_type] == "Server for Virtual Guest" then
    puts "#{rel[:full_node_name]} is a vmguest in cluster #{rel[:parent_system]}"
    vm_id = find_vm(rel[:full_node_name])
    vmhost_id = find_vmhost(rel[:parent_system])
    puts "vm: #{vm_id} is in cluster #{vmhost_id}"
  end
  #
end


#

#puts @neo.list_indexes
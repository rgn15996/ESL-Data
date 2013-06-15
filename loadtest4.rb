require 'csv'
require 'rubygems'
require 'neography'
require "#{File.dirname(__FILE__)}/esldata"

def load_data(nodes, node_type)
  @neo = Neography::Rest.new
  create_batch = Array.new

  puts "loading node type: #{node_type}"

  nodes.each_slice(100) do |node_batch|
    node_batch.each do |node|
      create_batch << [:create_node, {"name" => "#{node[:full_node_name]}", "type" => node_type}]
    end
  
    node_batch.each_with_index do |node, i|
      create_batch << [:add_node_to_index, node_type, "name", "#{node[:full_node_name]}", "{#{i}}"]
    end

    print "."

    batch_result = @neo.batch *create_batch
    create_batch.clear
    batch_result
  end
  puts ""
end

srvs = Array.new

Esldata.load_servers(srvs)
Esldata.del_deinstalled(srvs)

vms = Esldata.find_vmguests(srvs)
vmhosts = Esldata.find_vmhosts(srvs)

batch_result = load_data(vms, "vm")
batch_result = load_data(vmhosts, "vmhost")

puts batch_result
#

#puts @neo.list_indexes
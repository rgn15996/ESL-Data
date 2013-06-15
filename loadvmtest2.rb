require 'csv'
require 'rubygems'
require 'neography'
require "#{File.dirname(__FILE__)}/esldata"

def load_data(nodes, node_type)
  neo = Neography::Rest.new
  create_batch = Array.new

  puts "loading node type: #{node_type}"

  nodes.each_slice(500) do |node_batch|
    node_batch.each do |node|
      create_batch << [:create_node, {"name" => "#{node}", "type" => node_type}]
    end
  
    node_batch.each_with_index do |node, i|
      create_batch << [:add_node_to_index, node_type, "name", "#{node}", "{#{i}}"]
    end
    print "."
    batch_result = neo.batch *create_batch
    create_batch.clear
    batch_result
  end
  puts ""
end

srvs = Array.new
vms = Array.new
clusters = Array.new
hosts = Array.new
batch_array = Array.new

ESLdata.load_all_vms(srvs)

puts "Loaded #{srvs.count} VM servers"
srvs.each{ |sys| vms << sys[:dns_name].downcase unless sys[:dns_name] == "#UNDEFINED#"}
srvs.each{ |sys| clusters << sys[:cluster]}
srvs.each{ |sys| hosts << sys[:host].downcase}

puts "There are #{vms.uniq.count} virtual servers"

puts "There are #{clusters.uniq.count} clusters"
#clusters.uniq.each {|s| puts "#{s} count: #{clusters.count(s)}"}

puts "There are #{hosts.uniq.count} VMWare hosts"

load_data(vms.uniq, "vm")
load_data(clusters.uniq,"cluster")
load_data(hosts.uniq,"host")

@neo = Neography::Rest.new

srvs.each do |srv|
  vm = srv[:dns_name].downcase
  cluster = srv[:cluster]
  host = srv[:host].downcase

  if vm != '#UNDEFINED#' then
    # node_vm = @neo.get_node_index("vm", "name", vm)
    # node_cluster = @neo.get_node_index("cluster", "name", cluster)
    # node_host = @neo.get_node_index("host", "name", host)
  
    # @neo.create_relationship("IS_HOSTED_ON", node_vm, node_host)
    # @neo.create_relationship("HOSTS", node_host, node_vm)
    # @neo.create_relationship("IS_MEMBER_OF", node_host, node_cluster)
    # @neo.create_relationship("CONTAINS", node_cluster, node_host)
    batch_result = @neo.execute_query("START vm = node:vm(name = \"#{vm}\"), 
                      cluster = node:cluster(name = \"#{cluster}\"),
                      host = node:host(name = \"#{host}\")
                      CREATE UNIQUE vm-[:IS_HOSTED_ON]->cluster
                      CREATE UNIQUE cluster-[:HOSTS]->vm
                      CREATE UNIQUE host-[:IS_MEMBER_OF]->cluster
                      CREATE UNIQUE cluster-[:CONTAINS]->host
                      RETURN vm.name;")

    print "."
  end
end

#puts @neo.list_indexes
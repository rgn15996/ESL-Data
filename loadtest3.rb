require 'csv'
require 'rubygems'
require 'neography'
require "#{File.dirname(__FILE__)}/esldata"


count = 0
srvs = Array.new

node_list = Array.new
create_batch = Array.new

ESLdata.load_servers(srvs)

node_list = srvs.map { |srv| srv[:full_node_name]}

@neo = Neography::Rest.new

srvs.each_slice(100) do |srv_batch|

  srv_batch.each do |srv|
    node_data = {"name" => "#{srv[:full_node_name]}", "type" => "#{srv[:system_type]}"}
    create_batch << [:create_node, node_data]
  end

  srv_batch.each_with_index do |srv, i|
    create_batch << [:add_node_to_index, "name", "name", "#{srv[:full_node_name]}", "{#{i}}"]
    create_batch << [:add_node_to_index, "type", "type", "#{srv[:system_type]}", "{#{i}}"]
  end
  batch_result = @neo.batch *create_batch
  
  create_batch.clear
end
puts @neo.list_indexes
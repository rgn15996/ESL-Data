require 'csv'
require 'rubygems'
require 'neography'
require "#{File.dirname(__FILE__)}/esldata"

srvs = Array.new
sol_data = Array.new
sols = Array.new
create_batch = Array.new
node_data = Hash.new
nodes = Array.new


ESLdata.load_servers(srvs)
ESLdata.load_solutions(sol_data)
ESLdata.del_deinstalled(srvs)

@neo = Neography::Rest.new

# srvs.each_with_index do |srv,i|

#   # node_data.clear
#   # srv.each { |key, value| node_data[key] = value }

#   nodes[i+1] = @neo.create_node("full_node_name" => srv[:full_node_name])

#   print "."
# end
srvs.each_slice(200) do |srv_batch|
  srv_batch.each do |srv|
    node_data.clear
    srv.each { |key, value| node_data[key] = value }
    create_batch << [:create_node, node_data.clone] # NOte: CLONE!
  end
  batch_result = @neo.batch *create_batch
  create_batch.clear
  print "."
end

sol_data.each do |item|
  sols << item[:solution_name]
end
sols.uniq.each_slice(200) do |sol_batch|
	sol_batch.each do |sol|
		node_data.clear
		create_batch << [:create_node, {"name" => sol, "type" => "solution"}]
	end
  batch_result = @neo.batch *create_batch
  create_batch.clear
  print "."
end
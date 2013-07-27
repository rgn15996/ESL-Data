require 'csv'
require 'rubygems'
require 'neography'
require "#{File.dirname(__FILE__)}/esldata"

srvs = Array.new

node_data = Hash.new
create_batch = Array.new
sub_batch = Array.new

ESLdata.load_servers(srvs)
ESLdata.del_deinstalled(srvs)

@neo = Neography::Rest.new

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

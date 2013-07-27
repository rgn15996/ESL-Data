require 'csv'
require 'rubygems'
require 'neography'
require "#{File.dirname(__FILE__)}/esldata"

data = Array.new
hsns = Array.new
create_batch = Array.new

@neo = Neography::Rest.new

ESLdata.load_hsns(data)

data.each do |item|
  hsns << item[:solution_name]
end

hsns.uniq.each_slice(100) do |hsn_batch|
  create_batch.clear
  hsn_batch.each do |hsn|
  	create_batch << [:create_node, {"name" => hsn, "type" => "hsn"}]
  end
  @neo.batch *create_batch
  print "."
end
require 'rubygems'
require 'neography'
require "#{File.dirname(__FILE__)}/esldata"

rels = Array.new
@neo = Neography::Rest.new

stuff = @neo.create_node
puts stuff
# stuff2 = @neo.create_nodes(5)
# puts stuff2
@neo.set_node_properties(stuff, {"weight" => 200})

node = @neo.get_node(stuff)
puts node
w = @neo.get_node_properties(stuff, ["weight"])
puts "weight is #{w}"
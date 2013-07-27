require 'rubygems'
require 'neography'
#require "#{File.dirname(__FILE__)}/esldata"

@neo = Neography::Rest.new

query_string = "MATCH n WHERE n.system_type! = 'server' " + 
               "SET n:server " +
               "RETURN n.full_node_name;"
@neo.execute_query(query_string)

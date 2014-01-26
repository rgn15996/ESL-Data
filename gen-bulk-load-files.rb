#
# Generate Node and relationship CSV files for loading ESL data into Neo4j
#
# Richard Noble, Jan 25th 2014
#
#
require 'csv'
require 'rubygems'
require 'json'
require "#{File.dirname(__FILE__)}/esldata"

srvs = Array.new

# open nodes file for writing

nodefile = File.open('nodes.csv', "w")

# Load basic CI data into an array
ESLdata.load_servers(srvs)

puts "There are #{srvs.length} servers"

puts "Writing header row"
nodefile.write("name\tl:label\tstatus\n")

srvs.each_with_index do |srv, index|
	#puts index, srv[:full_node_name]
	# nodefile.write(index)
	# nodefile.write("\t")
	nodefile.write(srv[:full_node_name])
	nodefile.write("\t")
	nodefile.write("CI\t")
	nodefile.write(srv[:system_status])
	nodefile.write("\n")
end

nodefile.close()


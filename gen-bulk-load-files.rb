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
sols = Array.new
solmap = Array.new

# open nodes file for writing

ci_file = File.open('ci.csv', "w")
sol_file = File.open('sol.csv', "w")
sol_rel_file = File.open('sol_rels.csv', "w")

# Load basic CI data into an array
ESLdata.load_servers(srvs)

# puts "Server fields"
# sizy = 0
# srvs[0].each do |key,value|
#   puts "#{sizy} #{key}"
#   sizy += 1
# end

# Load business solution names (HSNs)
ESLdata.load_business_solutions(sols)

# puts "Solution fields"

# sizy = 0
# sols[0].each do |key,value|

#   puts "#{sizy} #{key}"
#   sizy += 1
# end

srv_length = srvs.length
puts "There are #{srvs.length} servers, #{srvs.uniq.length} unique"
puts "There are #{sols.length} business solutions, #{sols.uniq.length} unique"

puts "Write CI header row"

ci_file.write("l:label\t")
indx = 1
srvs[0].each do |key,value|
	ci_file.write("#{key}")
	if indx < srvs[0].length then
		ci_file.write("\t")
	else
		ci_file.write("\n")
	end
	indx += 1
end

puts "Write CI data..."

srvs.each_with_index do |srv, index|
	ci_file.write("ci\t")
	indx = 1
	srv.each do |key,value|
		ci_file.write("#{value}")
		if indx < srvs[0].length then
			ci_file.write("\t")
		else
			ci_file.write("\n")
		end
		indx += 1
	end
end


puts "Write Sol header row"

sol_file.write("l:label\t")
indx = 1
sols[0].each do |key,value|
	sol_file.write("#{key}")
	if indx < sols[0].length then
		sol_file.write("\t")
	else
		sol_file.write("\n")
	end
	indx += 1
end

puts "Write Solution data..."

sols.each_with_index do |sol, index|
	sol_file.write("solution\t")
	indx = 1
	sol.each do |key,value|
		sol_file.write("#{value}")
		if indx < sols[0].length then
			sol_file.write("\t")
		else
			sol_file.write("\n")
		end
		indx += 1
	end
end
ci_file.close()
sol_file.close()

# Load solution to ci mappings
ESLdata.load_solutions(solmap)
puts "Solution fields"

sizy = 0
solmap[0].each do |key,value|

  puts "#{sizy} #{key}"
  sizy += 1
end

solmap.each do |inst|
	srvs.each_with_index do |srv, indx_srv|
		if srv[:full_node_name] == inst[:full_node_name] then
			# found the server in the srvs array
			sols.each_with_index do |sol, indx_sol|
				if sol[:business_service] == inst[:solution_name] then
					sol_rel_file.write(indx_srv)
					sol_rel_file.write("\t")
					sol_rel_file.write(indx_sol+srv_length)
					sol_rel_file.write("\t")
					sol_rel_file.write("IS_COMPONENT_OF")
					sol_rel_file.write("\n")
			  end
			end
		end
	end
end

sol_rel_file.close()
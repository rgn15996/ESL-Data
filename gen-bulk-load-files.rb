#
# Generate Node and relationship CSV files for loading ESL data into Neo4j
#
# Richard Noble, Jan 25th 2014
#
#
require 'csv'
require 'rubygems'
# require 'json'
require "#{File.dirname(__FILE__)}/esldata"

srvs = Array.new
sols = Array.new
solmap = Array.new
ci_rels = Array.new
assets = Array.new
doms_dc2 = Array.new
doms_dc3 = Array.new
doms_wynyard = Array.new
doms = Array.new

# open nodes file for writing

ci_file = File.open('ci.csv', "w")
sol_file = File.open('sol.csv', "w")
sol_rel_file = File.open('sol_rels.csv', "w")
ci_rel_file = File.open('ci_rels.csv', "w")

# Load basic CI data into an array
ESLdata.load_servers(srvs)

# add asset fields
# This is a bit of a kludge, but it'll get us working...

srvs.each do |srv|
	srv[:asset_number] = ""
	srv[:asset_owner] = ""
	srv[:manufacturer] = ""
	srv[:purchase_date] = ""
	srv[:serial_number] = ""
	srv[:system_model] = ""
	srv[:doms_rfid] = ""
	srv[:doms_serial_number] = ""
	srv[:doms_model_type] = ""
	srv[:doms_model_name] = ""
	srv[:doms_brand_name] = ""
end

# load asset sheet
ESLdata.load_assets(assets)

# load doms data

ESLdata.load_doms(doms_dc2, "doms_dc2.csv")
ESLdata.load_doms(doms_dc3, "doms_dc3.csv")
ESLdata.load_doms(doms_wynyard, "doms_wynyard.csv")

doms.concat doms_dc2
doms.concat doms_dc3
doms.concat doms_wynyard

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

# Add asset data to the ci data

puts "Adding asset information to CI list"
srvs.each_with_index do |srv, indx_srv|
	percent = (indx_srv * 100 / srv_length) 
  print "\r#{percent}% complete"
	assets.each do |asset|
		if asset[:full_node_name] ==srv[:full_node_name] then
			srv[:asset_number] = asset[:asset_number]
			srv[:asset_owner] = asset[:asset_owner]
			srv[:manufacturer] = asset[:manufacturer]
			srv[:purchase_date] = asset[:purchase_date]
			srv[:serial_number] = asset[:serial_number]
			srv[:system_model] = asset[:system_model]
			srv[:doms_rfid] = asset[:doms_rfid]
		end
	end
end
print "\n"

puts "Adding DOMS information to CI list"
srvs.each_with_index do |srv, indx_srv|
	percent = (indx_srv * 100 / srv_length) 
  print "\r#{percent}% complete"
	doms.each do |device|
		if device[:rfid_tag] == srv[:doms_rfid] then
			srv[:doms_serial_number] = device[:serial_number]
			srv[:doms_model_type] = device[:model_type]
			srv[:doms_model_name] = device[:model_name]
			srv[:doms_brand_name] = device[:brand_name]
		end
	end
end
print "\n"
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

# sizy = 0
# solmap[0].each do |key,value|

#   puts "#{sizy} #{key}"
#   sizy += 1
# end

puts "write solution relationship header"

sol_rel_file.write("start\tend\ttype\n")

puts "Write solution relationship data"
sol_rels_length = solmap.length
solmap.each_with_index do |inst, indx_rel|
  percent = (indx_rel * 100 / sol_rels_length) 
  print "\r#{percent}% complete"
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
print "\n"

sol_rel_file.close()
# load ci relationships
ESLdata.load_relations(ci_rels)

puts "write ci relationship header"

ci_rel_file.write("start\tend\ttype\trelation\n")

puts "Write ci relationship data"
# loop through the ci relationships and for each...
# go through the ci list finding the child and parent then 
# output the child, parent relation to csv file
#
ci_rels_length = ci_rels.length
puts "#{ci_rels_length} relations"
ci_rels.each_with_index do |rel, indx_rel|
	percent = (indx_rel * 100 / ci_rels_length) 
	print "\r#{percent}% complete"
	parent = 0
	child = 0
	relation = ""
	srvs.each_with_index do |srv, indx_srv|
		if srv[:full_node_name] == rel[:full_node_name] then
			child = indx_srv
		end
		if srv[:full_node_name] == rel[:parent_system] then
			parent = indx_srv
			relation = rel[:relation_type]
		end
	end
	if child && parent then
		ci_rel_file.write(child)
		ci_rel_file.write("\t")
		ci_rel_file.write(parent)
		ci_rel_file.write("\t")
		ci_rel_file.write("DEPENDS_ON\t")
		ci_rel_file.write(relation)
		ci_rel_file.write("\n")
		# puts "child: #{child} parent: #{parent} relation: #{relation}"
	else
		puts "--- NO RELATION --- for #{rel[:full_node_name]}"
	end
end
print "\n"

ci_rel_file.close()

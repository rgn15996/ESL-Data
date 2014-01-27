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

# open nodes file for writing

ci_file = File.open('ci.csv', "w")
sol_file = File.open('sol.csv', "w")

# Load basic CI data into an array
ESLdata.load_servers(srvs)

puts "Server fields"
sizy = 0
srvs[0].each do |key,value|
  puts "#{sizy} #{key}"
  sizy += 1
end

# Load business solution names (HSNs)
ESLdata.load_business_solutions(sols)

puts "Solution fields"

sizy = 0
sols[0].each do |key,value|

  puts "#{sizy} #{key}"
  sizy += 1
end

puts "There are #{srvs.length} servers, #{srvs.uniq.length} unique"
puts "There are #{sols.length} business solutions, #{sols.uniq.length} unique"

puts "Writing CI header row"
puts "class is #{srvs[0].length}"

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

#ci_file.write("name\tl:label\tstatus\n")

srvs.each_with_index do |srv, index|
	ci_file.write("CI\t")
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

ci_file.close()
sol_file.close()


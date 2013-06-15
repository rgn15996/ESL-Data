require 'csv'
require 'rubygems'
require 'neography'


count = 0
srvs = Array.new
system_types = Array.new
os_versions = Array.new
virt_roles = Array.new
add_nodes = Array.new
commands = Array.new
index_commands = Array.new

puts "Loading Server data"
CSV.foreach("esl_aviva_1_srv.csv", {:headers => true, :header_converters => :symbol, :col_sep => "|"}) do |row|
  # puts "Loading node #{row[:full_node_name]}"
  srvs[count] = row
  srvs[count][:id] = count
  # puts srvs[count][:full_node_name]
  # puts srvs[count][:contract_service_level]
  count += 1
end
puts "Loaded #{count} nodes from server data"
# System types?
srvs.each do |sys|
  # puts "#{sys[:full_node_name]} is a #{sys[:system_type]}"
  system_types << sys[:system_type]
  os_versions << sys[:os_version]
  virt_roles << sys[:virtualization_role]
end
puts "There are #{system_types.uniq.count} system types"
system_types.uniq.each {|s| puts "#{s} count: #{system_types.count(s)}"}
puts "There are #{os_versions.uniq.count} OS vesions"
os_versions.uniq.each {|s| puts "#{s} count: #{os_versions.count(s)}"}
puts "There are #{virt_roles.uniq.count} virtualisation roles"
virt_roles.uniq.each {|s| puts "#{s} count: #{virt_roles.count(s)}"}
id = 0
add_nodes = srvs.map do |srv|
  #[:create_node, {"name" => srv[:full_node_name], "os_version" => srv[:os_version]}]
  [:create_node, {"name" => srv[:full_node_name]}]
end

@neo = Neography::Rest.new

add_nodes.each_slice(100) do |node_batch|
  puts "."

  node_batch.each_index do |i|
    puts "i is #{i}"
    puts node_batch[i]
    #index_commands << [:add_node_to_index, "nodes_index", "Name", node_batch[i][:full_node_name], "{#{i}}"]
  end
  commands = node_batch << index_commands
  #puts commands
  #@neo.batch *commands
  index_commands.clear
  commands.clear
end
# @neo.batch *add_nodes
#
#
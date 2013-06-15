require 'csv'
require 'rubygems'
require 'neography'


count = 0
srvs = Array.new
system_types = Array.new
os_versions = Array.new
virt_roles = Array.new
node_list = Array.new
create_batch = Array.new

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
node_list = srvs.map { |srv| srv[:full_node_name]}

@neo = Neography::Rest.new

node_list.each_slice(100) do |node_batch|
  puts "."

  node_batch.each_index { |i| create_batch << [:create_node, {"name" => "#{node_batch[i]}"}]}
  node_batch.each_index { |i| create_batch << [:add_node_to_index, "name", "name", "#{node_batch[i]}", "{#{i}}"]}
  batch_result = @neo.batch *create_batch
  #puts batch_result
  create_batch.clear
end
puts @neo.list_indexes
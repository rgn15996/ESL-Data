require 'csv'
require 'rubygems'
require "#{File.dirname(__FILE__)}/esldata"



srvs = Array.new
vms = Array.new
virtual_machines = Array.new
system_types = Array.new
os_versions = Array.new
virt_roles = Array.new
virt_types = Array.new
sys_status = Array.new



ESLdata.load_servers(srvs)
# ESLdata.load_all_vms(virtual_machines)
puts "\nremoving deinstalled...\n"

ESLdata.del_deinstalled(srvs)

puts "now there are #{srvs.length} left"

vms = ESLdata.find_vmguests(srvs)

puts "There are #{vms.length} Virtual guests"

srvs.each do |sys|
  # puts "#{sys[:full_node_name]} is a #{sys[:system_type]}"
  system_types << sys[:system_type]
  os_versions << sys[:os_version]
  virt_roles << sys[:virtualization_role]
  virt_types << sys[:virtualization_technology]
  sys_status << sys[:system_status]
  if ESLdata.isvmguest(sys) then vmguests << sys

end

puts "There are #{system_types.uniq.count} system types"
puts "================================================="
system_types.uniq.each {|s| puts "#{s} count: #{system_types.count(s)}"}
puts "--------------"
puts "There are #{os_versions.uniq.count} OS vesions"
puts "================================================="
os_versions.uniq.each {|s| puts "#{s} count: #{os_versions.count(s)}"}
puts "--------------"
puts "There are #{virt_roles.uniq.count} virtualisation roles"
puts "================================================="
virt_roles.uniq.each {|s| puts "#{s} count: #{virt_roles.count(s)}"}
puts "--------------"
puts "There are #{virt_types.uniq.count} virtualisation Technologies"
puts "================================================="
virt_types.uniq.each {|s| puts "#{s} count: #{virt_types.count(s)}"}
puts "--------------"
puts "There are #{sys_status.uniq.count} status type"
puts "================================================="
sys_status.uniq.each {|s| puts "#{s} count: #{sys_status.count(s)}"}
puts "--------------"
#node_list = srvs.map { |srv| srv[:full_node_name]}


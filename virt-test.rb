require 'csv'
require 'rubygems'
require "#{File.dirname(__FILE__)}/esldata"



srvs = Array.new
vms = Array.new
vmguests = Array.new
vmhosts = Array.new
lpars = Array.new
pseries = Array.new
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

srvs.each do |sys|
  # puts "#{sys[:full_node_name]} is a #{sys[:system_type]}"
  system_types << sys[:system_type]
  os_versions << sys[:os_version]
  virt_roles << sys[:virtualization_role]
  virt_types << sys[:virtualization_technology]
  sys_status << sys[:system_status]
  vmguests << sys if ESLdata.isvmguest(sys)
  vmhosts << sys if ESLdata.isvmhost(sys)

  lpars << sys if ESLdata.islpar(sys)
  pseries << sys if ESLdata.ispseries(sys)

end

puts "There are #{vmguests.count} vmguests"
puts "================================================="
puts "There are #{vmhosts.count} vmhosts"
puts "================================================="
puts "There are #{lpars.count} lpars"
puts "================================================="
puts "There are #{pseries.count} pseries"
puts "================================================="
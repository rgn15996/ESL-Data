require 'csv'
require 'rubygems'
require "#{File.dirname(__FILE__)}/esldata"



srvs = Array.new

ESLdata.load_servers(srvs)

puts "Loaded #{srvs.length} CIs..."

puts srvs[1].headers

# puts "There are #{system_types.uniq.count} system types"
# puts "================================================="
# system_types.uniq.each {|s| puts "#{s} count: #{system_types.count(s)}"}
# puts "--------------"
# puts "There are #{os_versions.uniq.count} OS vesions"
# puts "================================================="
# os_versions.uniq.each {|s| puts "#{s} count: #{os_versions.count(s)}"}
# puts "--------------"
# puts "There are #{virt_roles.uniq.count} virtualisation roles"
# puts "================================================="
# virt_roles.uniq.each {|s| puts "#{s} count: #{virt_roles.count(s)}"}
# puts "--------------"
# puts "There are #{virt_types.uniq.count} virtualisation Technologies"
# puts "================================================="
# virt_types.uniq.each {|s| puts "#{s} count: #{virt_types.count(s)}"}
# puts "--------------"
# puts "There are #{sys_status.uniq.count} status type"
# puts "================================================="
# sys_status.uniq.each {|s| puts "#{s} count: #{sys_status.count(s)}"}
# puts "--------------"
# node_list = srvs.map { |srv| srv[:full_node_name]}

# puts node_list

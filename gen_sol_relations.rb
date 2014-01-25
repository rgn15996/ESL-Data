require 'csv'
require 'rubygems'

require "#{File.dirname(__FILE__)}/esldata"

sol = Array.new
ESLdata.load_solutions(sol)

sol.each_slice(200) do |sol_batch|
  
  query = "begin\n"

  sol_batch.each do |sol|

    ci = sol[:full_node_name] 
    sol_name = sol[:solution_name]

    query += "MATCH n,m " +
             "WHERE n.full_node_name = '#{ci}' " +
             "AND m.name = '#{sol_name}' " +
             "CREATE UNIQUE n-[r:IS_COMPONENT_OF]->m;\n "
  #           "RETURN ID(m),ID(n);\n" 
  end
  query += "commit\nexit\n"
  puts query
end


  
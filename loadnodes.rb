require 'csv'
require 'rubygems'
require 'neography'

count = 0

@neo = Neography::Rest.new

CSV.foreach("esl_aviva_1_srv.csv", {:headers => true, :header_converters => :symbol, :col_sep => "|"}) do |row|
  puts "Loading node #{row[:full_node_name]}"
  node = @neo.create_node("name" => row[:full_node_name])
  count += 1
end
puts "Loaded #{count} nodes"
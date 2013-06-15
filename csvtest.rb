require 'csv'

count = 0

CSV.foreach("esl_aviva_1_srv.csv", {:headers => true, :header_converters => :symbol, :col_sep => "|"}) do |row|
  puts "Node is called #{row[:full_node_name]}"
  count += 1
end
puts "There are #{count} nodes"
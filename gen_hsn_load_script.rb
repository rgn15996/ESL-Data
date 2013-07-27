require 'csv'
require 'rubygems'

require "#{File.dirname(__FILE__)}/esldata"

data = Array.new
hsns = Array.new


ESLdata.load_hsns(data)

data.each do |item|
  hsns << item[:solution_name]
end

hsns.uniq.each_slice(100) do |hsn_batch|
  query = "begin\n"
  hsn_batch.each do |hsn|
    query += "MERGE (m:hsn {name:'#{hsn}'}) RETURN m;\n"
  end
  query += "commit\nexit\n"
  puts query
end


  
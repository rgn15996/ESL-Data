require 'csv'
require 'rubygems'
require 'neography'
require "#{File.dirname(__FILE__)}/esldata"

data = Array.new
hsns = Array.new

@neo = Neography::Rest.new

ESLdata.load_hsns(data)

data.each do |item|
  hsns << item[:solution_name]
end

hsns.uniq.each_slice(100) do |hsn_batch|
  tx = @neo.begin_transaction
  # @neo.keep_transaction(tx)

  hsn_batch.each do |hsn|
    query_string = "MERGE (m:hsn {name:'#{hsn}'}) RETURN m;\n"
    @neo.in_transaction(tx, query_string)
  end
  @neo.commit_transaction(tx)
  print "."
end
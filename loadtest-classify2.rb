require 'csv'
require 'rubygems'
require 'json'
require "#{File.dirname(__FILE__)}/esldata"

count = 0
srvs = Array.new
hash = Hash.new

puts "Loading Server data"
ESLdata.load_servers(srvs)

puts "\nremoving deinstalled...\n"
ESLdata.del_deinstalled(srvs)

puts "Loaded #{srvs.length} nodes from server data"

# System types?
funny_types = 0
srvs.each_slice(500) do |sys_batch|
  cypher_query = { :statements => []}
  index = 0
  sys_batch.each do |sys|
    index += 1
    type = ESLdata.classify_server(sys)
    if type == "Unknown" then
      funny_types += 1
    end
    query = ESLdata.constructQuery(sys, type, index)
    hash[:statement] = "#{query}"
    cypher_query[:statements] << hash.clone #"{ :statement => '#{query}' }"
    hash.clear
  end

  # puts cypher_query

  response = ESLdata.open_transaction()
  #puts cypher_query.to_json

  if response.code == 201 then
    url = response.headers[:location].to_s
    # res = RestClient.post response.headers[:location], 
    #   cypher_query.to_json, 
    #   {:content_type => :json, :accept => :json}
    res = ESLdata.transact_query(url, cypher_query.to_json)

    commit_url = JSON.parse(res)["commit"]
    res2 = ESLdata.commit_transaction(commit_url)
    print "."
  end
end
print "There are still #{funny_types} funny nodes"

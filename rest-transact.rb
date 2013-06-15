require 'rubygems'
require 'rest_client'
require 'json'

BASE_URL = 'http://localhost:7474/db/data'

def open_transaction
	url = BASE_URL + '/transaction'

	request = ""
	request_headers = {:content_type => :json, :accept => :json}
	response = RestClient.post url, request, request_headers
end

response = open_transaction()

if response.code == 201 then
	url = response.headers[:location].to_s
	
	cypher = { :statements => [
		{:statement => 'CREATE (n:vm {name: "nodey", size: "small"}) RETURN id(n)'}
		]}
	
	res = RestClient.post response.headers[:location], 
		cypher.to_json, 
		{:content_type => :json, :accept => :json}
	
	commit_url = JSON.parse(res)["commit"]
	res2 = RestClient.post commit_url, "", 
		{:content_type => :json, :accept => :json}

end




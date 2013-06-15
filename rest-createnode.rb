require 'rubygems'
require 'rest_client'
require 'json'

url = 'http://localhost:7474/db/data/node'

(1..1000).each do |n|
	response = RestClient.post url,
		{"name" => "Bob", "size" => "Large" }, 
		:accept => :json
	puts n
end

# puts response.code
# puts response.headers[:content_type]
# puts response.headers[:content_length]
# puts
# hashofstuff = JSON.parse(response.body)

# p hashofstuff['labels']
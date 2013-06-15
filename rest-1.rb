require 'rubygems'
require 'rest_client'
require 'json'

url = 'http://localhost:7474/db/data/node/0'

response = RestClient.get(url)

puts response.code
puts response.headers[:content_type]
puts response.headers[:content_length]
puts
hashofstuff = JSON.parse(response.body)

p hashofstuff['self']
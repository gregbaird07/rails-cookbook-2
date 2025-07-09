#!/usr/bin/env ruby

# Test script to simulate the CSRF behavior

require 'net/http'
require 'uri'
require 'json'

# Test the parse_url endpoint
uri = URI('http://localhost:3000/recipes/parse_url')
http = Net::HTTP.new(uri.host, uri.port)

# First, get the CSRF token from the new recipe page
get_uri = URI('http://localhost:3000/recipes/new')
get_response = http.get(get_uri)
puts "GET response status: #{get_response.code}"

# Extract CSRF token from the response
csrf_token = get_response.body.match(/name="csrf-token" content="([^"]+)"/)[1] rescue nil
puts "CSRF token: #{csrf_token}"

# Now test the POST request
request = Net::HTTP::Post.new(uri)
request['Content-Type'] = 'application/x-www-form-urlencoded'
request['X-CSRF-Token'] = csrf_token
request['X-Requested-With'] = 'XMLHttpRequest'

# Use form data
request.body = "url=https://example.com/recipe"

response = http.request(request)
puts "POST response status: #{response.code}"
puts "POST response body: #{response.body}"

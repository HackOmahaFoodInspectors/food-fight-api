require 'sinatra'
require 'json'

post '/user' do
  json = JSON.parse(request.body.read)
    
  "{ \"result\" : \"#{json["email"]}\" }\n"
end

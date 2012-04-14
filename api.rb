require 'sinatra'
require 'json'

before do
  content_type :json
end

# create a new user
post '/user', :provides => 'json' do
  json = JSON.parse(request.body.read)

  # actually setup of new users goes here, or replying that they are already created
  reply = Hash.new
  reply[:result] = json["email"]
  
  reply.to_json
end

# get a users ranking
get '/leaderboard/:email', :provides => 'json' do
  reply = Hash.new
  
  reply[:ranking] = 35
  reply[:total] = 254
  
  reply.to_json
end

# submit the results of a matchup
post '/matchup', :provides => 'json' do
  json = JSON.parse(request.body.read)
  
  # actually write out the results of this match
  
  reply = Hash.new
  
  reply[:restaurant_1] = Hash.new
  reply[:restaurant_1][:name] = json[:restaurant_1][:name]
  reply[:restaurant_1][:address] = json[:restaurant_1][:address]
  reply[:restaurant_1][:rating] = 'EXCELLENT'
  reply[:restaurant_1][:user_rating] = 4.52
  
  reply[:restaurant_2] = Hash.new
  reply[:restaurant_2][:name] = json[:restaurant_2][:name]
  reply[:restaurant_2][:address] = json[:restaurant_2][:address]
  reply[:restaurant_2][:rating] = 'EXCELLENT'
  reply[:restaurant_2][:user_rating] = 4.52
  
  reply.to_json
end

# get a matchup for the user
get '/matchup', :provides => 'json' do
  reply = Hash.new
  
  reply[:restaurant_1] = Hash.new
  reply[:restaurant_1][:name] = 'Restaurant Company'
  reply[:restaurant_1][:address] = '1000 Example Street'
  reply[:restaurant_1][:photo] = 'http://example.com/1.jpg'
  reply[:restaurant_1][:tip] = 'Try the Sake! Best Wings in the World!'
  
  reply[:restaurant_2] = Hash.new
  reply[:restaurant_2][:name] = 'Restaurant Company'
  reply[:restaurant_2][:address] = '1000 Example Street'
  reply[:restaurant_2][:photo] = 'http://example.com/1.jpg'
  reply[:restaurant_2][:tip] = 'Try the Sake! Best Wings in the World!'
  
  reply.to_json
end
require 'sinatra'
require 'json'
require 'active_record'
require 'uri'

require_relative 'models/restaurant'
require_relative 'models/user'

@dbc = URI.parse(ENV['DATABASE_URL'] || 'sqlite3:/db/food_fight.sqlite3')

ActiveRecord::Base.establish_connection(
  :adapter  => @dbc.scheme == 'postgres' ? 'postgresql' : @dbc.scheme,
  :host     => @dbc.host,
  :username => @dbc.user,
  :password => @dbc.password,
  :database => @dbc.path[1..-1],
  :encoding => 'utf8'
)

enable :logging

before do
  content_type :json
end

# create a new user
get '/' do
  "Welcome to the Omaha Food Fight!"
end

post '/user' do
  json = JSON.parse(request.body.read)

  # actually setup of new users goes here, or replying that they are already created
  user = User.first(:conditions => ["name = ?", json["email"]])
  
  if user.nil?
    user = User.new
    user.name = json["email"]
    user.created_at = DateTime.now
    user.save
  end
  
  reply = Hash.new
  reply[:result] = user.name
  
  reply.to_json
end

# get a users ranking
get '/leaderboard/:email' do
  reply = Hash.new
  
  reply[:ranking] = 35
  reply[:total] = 254
  
  reply.to_json
end

# submit the results of a matchup
post '/matchup' do
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
get '/matchup' do
  max_range = Restaurant.count
  
  option_1_row = Random.rand(max_range) + 1
  option_2_row = Random.rand(max_range) + 1
  
  option_1 = Restaurant.first(:offset => option_1_row)
  option_2 = Restaurant.first(:offset => option_2_row)
  
  reply = Hash.new
  
  reply[:restaurant_1] = Hash.new
  reply[:restaurant_1][:name] = option_1.name
  reply[:restaurant_1][:address] = option_1.address
  reply[:restaurant_1][:photo] = option_1.image
  reply[:restaurant_1][:tip] = 'Try the Sake! Best Wings in the World!'
  
  reply[:restaurant_2] = Hash.new
  reply[:restaurant_2][:name] = 'Restaurant Company'
  reply[:restaurant_2][:address] = '1000 Example Street'
  reply[:restaurant_2][:photo] = 'http://example.com/1.jpg'
  reply[:restaurant_2][:tip] = 'Try the Sake! Best Wings in the World!'
  
  reply.to_json
end

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
  reply = Hash.new
  
  reply[:restaurant_1] = Hash.new
  reply[:restaurant_1][:name] = 'Restaurant #1'
  reply[:restaurant_1][:address] = '1000 Example Street'
  reply[:restaurant_1][:photo] = 'http://deep-ice-5394.heroku.com/food.jpg'
  reply[:restaurant_1][:tip] = 'Try the Sake! Best Wings in the World!'
  
  reply[:restaurant_2] = Hash.new
  reply[:restaurant_2][:name] = 'Restaurant #2'
  reply[:restaurant_2][:address] = '1000 Fake Street'
  reply[:restaurant_2][:photo] = 'http://deep-ice-5394.heroku.com/food.jpg'
  reply[:restaurant_2][:tip] = 'Try the Sake! Best Wings in the World!'
  
  reply.to_json
end

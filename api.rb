require 'sinatra'
require 'json'
require 'active_record'
require 'uri'
require 'elo'

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

get '/' do
  "Welcome to the Omaha Food Fight!"
end

# create a new user
post '/user' do
  json = JSON.parse(request.body.read)
  
  logger.info "recieved user create request #{json}"

  # actually setup of new users goes here, or replying that they are already created
  user = User.first(:conditions => ["name = ?", json["email"]])
  
  if user.nil?
    logger.info "creating new user " + json["email"]
    
    user = User.new
    user.name = json["email"]
    user.created_at = DateTime.now
    user.save
  else
    logger.warn "user #{user.name} already exits"
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
  
  user_result = json["user_result"]
  user_name = json["email"]
  
  # update user score if not anon
  if user_name != "anon"
    user = User.first(:conditions => ["name = ?", user_name])
    
    logger.info "updating user #{user.name} (#{user.wins} - #{user.losses}) as #{user_result}"
    
    user.update_score(user_result)
  end
  
  #update user ratings
  restaurant_1 = json["restaurant_1"]
  
  logger.info "searching for #{restaurant_1}"
  
  r1 = Restaurant.first(:conditions => ['name = ? and address = ?', restaurant_1["name"], restaurant_1["address"]])
  
  logger.info "updating results for #{r1}"
  
  p1 = Elo::Player.new(:rating => r1.user_rating)

  restaurant_2 = json["restaurant_2"]
  
  logger.info "searching for #{restaurant_2}"
  
  r2 = Restaurant.first(:conditions => ['name = ? and address = ?', restaurant_2["name"], restaurant_2["address"]])
  
  logger.info "updating results for #{r2}"
  
  p2 = Elo::Player.new(:rating => r2.user_rating)

  if restaurant_1["choice"]== 'winner'
    p1.wins_from p2
  else
    p2.wins_from p1
  end

  r1.update_attributes!(:user_rating => p1.rating)
  r2.update_attributes!(:user_rating => p2.rating)

  r1.update_score(restaurant_1["choice"])
  r2.update_score(restaurant_2["choice"])
  
  reply = Hash.new
  
  reply[:response] = "ok"
end

# get a matchup for the user
get '/matchup' do
  option_1 = Restaurant.get_opponent
  option_2 = Restaurant.get_opponent
  
  if option_1 == option_2
    option_2 = Restaurant.get_opponent
  end
  
  logger.info "sending #{option_1.name} vs #{option_2.name}"
  
  reply = Hash.new
  
  reply[:restaurant_1] = Hash.new
  reply[:restaurant_1][:name] = option_1.name
  reply[:restaurant_1][:address] = option_1.address
  reply[:restaurant_1][:photo] = option_1.photo
  reply[:restaurant_1][:tip] = option_1.tip
  reply[:restaurant_1][:rating] = option_1.rating
  reply[:restaurant_1][:user_rating] = option_1.user_rating
  
  reply[:restaurant_2] = Hash.new
  reply[:restaurant_2][:name] = option_2.name
  reply[:restaurant_2][:address] = option_2.address
  reply[:restaurant_2][:photo] = option_2.photo
  reply[:restaurant_2][:tip] = option_2.tip
  reply[:restaurant_2][:rating] = option_2.rating
  reply[:restaurant_2][:user_rating] = option_2.user_rating
  
  reply.to_json
end

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
  content_type :html
  erb :index
end

# get all the user info
get '/user' do
  users = User.find(:all)
  
  reply = []
  
  if users.empty?
    status 404
  else
    users.each do |user|
      reply_entry =  Hash.new
      reply_entry[:email] = user.name
      reply_entry[:wins] = user.wins
      reply_entry[:losses] = user.losses
      reply << reply_entry
    end
  end
  
  reply.to_json
end

# get user info
get '/user/:name' do
  logger.info "looking up user #{params[:name]}"
  
  user = User.first(:conditions => ["name = ?", params[:name]])
  
  reply = Hash.new
  
  if user.nil?
    status 404
  else
    reply[:email] = user.name
    reply[:wins] = user.wins
    reply[:losses] = user.losses
  end
  
  reply.to_json
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

  users = User.find(:all).sort!
  ranking = users.find_index {|x| x.name == params[:email]}
  reply = {
    :ranking => ranking + 1,
    :total => users.count
  }.to_json
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
    
    if user_result == 'winner'
      user.wins += 1
    else
      user.losses += 1
    end
    
    user.save
  end
  
  #update user ratings
  restaurant_1 = json["restaurant_1"]
  
  logger.info "searching for #{restaurant_1}"
  
  r1 = Restaurant.first(:conditions => ['name = ? and address = ?', restaurant_1["name"], restaurant_1["address"]])
  
  logger.info "updating results for #{r1.name} (#{r1.wins} - #{r1.losses})"
  
  p1 = Elo::Player.new(:rating => r1.user_rating)

  restaurant_2 = json["restaurant_2"]
  
  logger.info "searching for #{restaurant_2}"
  
  r2 = Restaurant.first(:conditions => ['name = ? and address = ?', restaurant_2["name"], restaurant_2["address"]])
  
  logger.info "updating results for #{r2.name} (#{r2.wins} - #{r2.losses})"
  
  p2 = Elo::Player.new(:rating => r2.user_rating)

  if restaurant_1["choice"]== 'winner'
    p1.wins_from p2
  else
    p2.wins_from p1
  end

  r1.update_attributes!(:user_rating => p1.rating)
  r2.update_attributes!(:user_rating => p2.rating)

  if restaurant_1["choice"] == 'winner'
    r1.wins += 1
  else
    r1.losses += 1
  end
  
  r1.save


  if restaurant_2["choice"] == 'winner'
    r2.wins += 1
  else
    r2.losses += 1
  end
  
  r2.save
  
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

get '/analytics' do
  content_type :html
  restaurants = Restaurant.find(:all).sort! {|x,y| x.user_rating <=> y.user_rating }
  @conflicting = restaurants.select { |r| r.conflicting_ratings? }
  @top_50 = restaurants.first(50)
  @bottom_50 = restaurants.last(50).reverse
  erb :analytics
end

# list all restauarnts
get '/restaurants' do
  restaurants = Restaurant.find(:all)
  
  reply = Array.new
  
  if restaurants.empty?
    halt 404
  else
    restaurants.each do |restaurant|
      reply_entry = Hash.new
      reply_entry[:name] = restaurant.name
      reply_entry[:address] = restaurant.address
      reply_entry[:rating] = restaurant.rating
      reply_entry[:user_rating] = restaurant.user_rating
      reply_entry[:wins] = restaurant.wins
      reply_entry[:losses] = restaurant.losses
      
      reply << reply_entry
    end
  end
  
  reply.to_json
end

# find restaurants with name
get '/restaurants/:name' do
  logger.info "looking up restaurant #{params[:name]}"
  
  restaurants = Restaurant.where('name = ?', params[:name].upcase)
  
  reply = Array.new
  
  if restaurants.empty?
    halt 404
  else
    restaurants.each do |restaurant|
      reply_entry = Hash.new
      reply_entry[:name] = restaurant.name
      reply_entry[:address] = restaurant.address
      reply_entry[:rating] = restaurant.rating
      reply_entry[:user_rating] = restaurant.user_rating
      reply_entry[:wins] = restaurant.wins
      reply_entry[:losses] = restaurant.losses
      
      reply << reply_entry
    end
  end
  
  reply.to_json
end

# find ratings with restaurants above threshold
get '/restaurants/rating/:rating' do
  logger.info "looking up restaurants with rating #{params[:rating]}"
  
  restaurants = Restaurant.where("rating = ?", params[:rating].upcase)

  reply = Array.new
  
  if restaurants.empty?
    halt 404
  else
    restaurants.each do |restaurant|
      reply_entry = Hash.new
      reply_entry[:name] = restaurant.name
      reply_entry[:address] = restaurant.address
      reply_entry[:rating] = restaurant.rating
      reply_entry[:user_rating] = restaurant.user_rating
      reply_entry[:wins] = restaurant.wins
      reply_entry[:losses] = restaurant.losses
      
      reply << reply_entry
    end
  end
  
  reply.to_json
end

# find restaurants with ratings below threshold
get '/restaurants/rating/:rating/above' do
  logger.info "looking up restaurants with rating above #{params[:rating]}"
  
  ratings_list = Array.new
  
  ratings_list << "SUPERIOR"
  
  if params[:rating].upcase == "FAIR"
    ratings_list << "FAIR" << "STANDARD" << "EXCELLENT"
  elsif params[:rating].upcase == "STANARD"
    ratings_list << "STANDARD" << "EXCELLENT"
  elsif params[:rating].upcase == "EXCELLENT"
    ratings_list << "EXCELLENT"
  end
  
  logger.info "rating group is #{ratings_list}"
  
  restaurants = Restaurant.where("rating in (?)", ratings_list)

  reply = Array.new
  
  if restaurants.empty?
    halt 404
  else
    restaurants.each do |restaurant|
      reply_entry = Hash.new
      reply_entry[:name] = restaurant.name
      reply_entry[:address] = restaurant.address
      reply_entry[:rating] = restaurant.rating
      reply_entry[:user_rating] = restaurant.user_rating
      reply_entry[:wins] = restaurant.wins
      reply_entry[:losses] = restaurant.losses
      
      reply << reply_entry
    end
  end
  
  reply.to_json
end

get '/restaurants/rating/:rating/below' do
  logger.info "looking up restaurants with rating below #{params[:rating]}"
  
  ratings_list = Array.new
  
  ratings_list << "FAIR"
  
  if params[:rating].upcase == "STANDARD"
    ratings_list << "STANDARD"
  elsif params[:rating].upcase == "EXCELLENT"
    ratings_list << "STANDARD" << "EXCELLENT"
  elsif params[:rating].upcase == "SUPERIOR"
    ratings_list << "STANDARD" << "EXCELLENT" << "SUPERIOR"
  end
  
  logger.info "rating group is #{ratings_list}"
  
  restaurants = Restaurant.where("rating in (?)", ratings_list)

  reply = Array.new
  
  if restaurants.empty?
    halt 404
  else
    restaurants.each do |restaurant|
      reply_entry = Hash.new
      reply_entry[:name] = restaurant.name
      reply_entry[:address] = restaurant.address
      reply_entry[:rating] = restaurant.rating
      reply_entry[:user_rating] = restaurant.user_rating
      reply_entry[:wins] = restaurant.wins
      reply_entry[:losses] = restaurant.losses
      
      reply << reply_entry
    end
  end
  
  reply.to_json
end

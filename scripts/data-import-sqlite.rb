require 'csv'
require 'active_record'
require '../models/restaurant'
require 'uri'

#This is a simple script to load data from the CSV file into a sqlite database.
@dbc = URI.parse(ENV['DATABASE_URL'] || 'sqlite3:/../db/food_fight.sqlite3')

ActiveRecord::Base.establish_connection(
  :adapter  => @dbc.scheme == 'postgres' ? 'postgresql' : @dbc.scheme,
  :host     => @dbc.host,
  :username => @dbc.user,
  :password => @dbc.password,
  :database => @dbc.path[1..-1],
  :encoding => 'utf8'
)
csv = CSV.read('../docs/food-inspections.csv')
csv.shift
csv.each do |line|
  restaurant = Restaurant.new
  restaurant.name = line[0].force_encoding('UTF-8')
  restaurant.rating = line[1]
  restaurant.address = line[3].force_encoding('UTF-8')
  restaurant.latitude = line[4]
  restaurant.longitude = line[5]
  restaurant.save
end

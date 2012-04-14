require 'csv'
require 'active_record'
ActiveRecord::Base.establish_connection(
  :adapter  => @dbc.scheme == 'postgres' ? 'postgresql' : @dbc.scheme,
  :host     => @dbc.host,
  :username => @dbc.user,
  :password => @dbc.password,
  :database => @dbc.path[1..-1],
  :encoding => 'utf8'
)


#This is a simple script to load data from the CSV file into a Postgres database.
conn = PG.connect(dbname: 'postgres')
csv = CSV.read('../docs/food-inspections.csv')
csv.shift
csv.each do |line|
  restaurant = Restaurant.new
  restaurant.name = line[0]
  restaurant.rating = line[1]
  restaurant.address = line[3]
  restaurant.latitude = line[4]
  restaurant.longitude = line[5]
  restaurant.save
end

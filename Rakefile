namespace :db do
  task :environment do
    require 'active_record'
    require 'uri'

    @dbc = URI.parse(ENV['DATABASE_URL'] || 'sqlite3:/db/food_fight.sqlite3')

    ActiveRecord::Base.establish_connection(
      :adapter  => @dbc.scheme == 'postgres' ? 'postgresql' : @dbc.scheme,
      :host     => @dbc.host,
      :username => @dbc.user,
      :password => @dbc.password,
      :database => @dbc.path[1..-1],
      :encoding => 'utf8',
      :min_messages => "WARNING"
    )
  end
  
  desc "Migrate the database"
  task(:migrate => :environment) do
    require 'logger'
    
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
  end
  
  desc "Migrate back down"
  task(:down => :environment) do
    require 'logger'
    
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.down("db/migrate")
  end
end
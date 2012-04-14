require 'sinatra'

post '/user' do
    @user = params[:id]
    
    "{ result: '#{@user}' }\n"
end

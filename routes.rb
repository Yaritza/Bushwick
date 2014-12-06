require 'sinatra'
Tilt.register Tilt::ERBTemplate, 'html.erb'


get '/' do
  "Hello, world"
end

get '/test' do
	erb :twitter_geocode_test
 end
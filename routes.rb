require "sinatra"
require "instagram"
require "json"
# require "

enable :sessions

CALLBACK_URL = "http://bushwick.herokuapp.com/oauth/callback"

Instagram.configure do |config|
  config.client_id = "553f2b4fa2384d3f833711dcfa68e586"
  config.client_secret = "e2a487865edd45af941f7c8c49892c3b"
  # For secured endpoints only
  #config.client_ips = '<Comma separated list of IPs>'
end

get "/connect" do
  '<a href="/oauth/connect">Connect with Instagram</a>'
end


get "/oauth/connect" do
  redirect Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
end

get "/oauth/callback" do
  response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)
  session[:access_token] = response.access_token
  redirect "/nav"
end

get "/nav" do
  erb :nav
end

get "/user_recent_media" do
  client = Instagram.client(:access_token => session[:access_token])
  user = client.user
  html = "<h1>#{user.username}'s recent media</h1>"
  for media_item in client.user_recent_media
    html << "<div style='float:left;'><img src='#{media_item.images.thumbnail.url}'><br/> <a href='/media_like/#{media_item.id}'>Like</a>  <a href='/media_unlike/#{media_item.id}'>Un-Like</a>  <br/>LikesCount=#{media_item.likes[:count]}</div>"
  end
  html
end

get '/media_like/:id' do
  client = Instagram.client(:access_token => session[:access_token])
  client.like_media("#{params[:id]}")
  redirect "/user_recent_media"
end

get '/media_unlike/:id' do
  client = Instagram.client(:access_token => session[:access_token])
  client.unlike_media("#{params[:id]}")
  redirect "/user_recent_media"
end

get "/user_media_feed" do
  client = Instagram.client(:access_token => session[:access_token])
  user = client.user
  html = "<h1>#{user.username}'s media feed</h1>"

  page_1 = client.user_media_feed(777)
  page_2_max_id = page_1.pagination.next_max_id
  page_2 = client.user_recent_media(777, :max_id => page_2_max_id ) unless page_2_max_id.nil?
  html << "<h2>Page 1</h2><br/>"
  for media_item in page_1
    html << "<img src='#{media_item.images.thumbnail.url}'>"
  end
  html << "<h2>Page 2</h2><br/>"
  for media_item in page_2
    html << "<img src='#{media_item.images.thumbnail.url}'>"
  end
  html
end

get "/location_recent_media" do
  client = Instagram.client(:access_token => session[:access_token])
  html = "<h1>Media from the Instagram Office</h1>"
  for media_item in client.location_recent_media(514276)
    html << "<img src='#{media_item.images.thumbnail.url}'>"
  end
  html
end

get "/media_search" do
  client = Instagram.client(:access_token => session[:access_token])
  html = "<h1>Get a list of media close to a given latitude and longitude</h1>"
  for media_item in client.media_search("37.7808851","-122.3948632")
    html << "<img src='#{media_item.images.thumbnail.url}'>"
  end
  html
end

get "/media_popular" do
  client = Instagram.client(:access_token => session[:access_token])
  html = "<h1>Get a list of the overall most popular media items</h1>"
  for media_item in client.media_popular
    html << "<img src='#{media_item.images.thumbnail.url}'>"
  end
  html
end

get "/user_search" do
  client = Instagram.client(:access_token => session[:access_token])
  html = "<h1>Search for users on instagram, by name or usernames</h1>"
  for user in client.user_search("instagram")
    html << "<li> <img src='#{user.profile_picture}'> #{user.username} #{user.full_name}</li>"
  end
  html
end

get "/location_search" do
  client = Instagram.client(:access_token => session[:access_token])
  html = "<h1>Search for a location by lat/lng with a radius of 5000m</h1>"
  for location in client.location_search("48.858844","2.294351","5000")
    html << "<li> #{location.name} <a href='https://www.google.com/maps/preview/@#{location.latitude},#{location.longitude},19z'>Map</a></li>"
  end
  html
end

get "/location_search_4square" do
  client = Instagram.client(:access_token => session[:access_token])
  html = "<h1>Search for a location by Fousquare ID (v2)</h1>"
  for location in client.location_search("3fd66200f964a520c5f11ee3")
    html << "<li> #{location.name} <a href='https://www.google.com/maps/preview/@#{location.latitude},#{location.longitude},19z'>Map</a></li>"
  end
  html
end

get "/tags" do
  client = Instagram.client(:access_token => session[:access_token])
  html = "<h1>Search for tags, get tag info and get media by tag</h1>"
  tags = client.tag_search('blacklivesmatter')
  html << "<h2>Tag Name = #{tags[0].name}. Media Count =  #{tags[0].media_count}. </h2><br/><br/>"
  for media_item in client.tag_recent_media(tags[0].name)
    html << "<img src='#{media_item.images.thumbnail.url}'>"
  end
  html
end

get "/limits" do
  client = Instagram.client(:access_token => session[:access_token])
  html = "<h1/>View API Rate Limit and calls remaining</h1>"
  response = client.utils_raw_response
  html << "Rate Limit = #{response.headers[:x_ratelimit_limit]}.  <br/>Calls Remaining = #{response.headers[:x_ratelimit_remaining]}"

  html
end

get '/tags.json' do
  client = Instagram.client(:access_token => session[:access_token])
  tags = client.tag_search('blacklivesmatter')
    content_type :json
  client.tag_recent_media(tags[0].name, {"count" => 1000}).to_json
end

def StateFromLatLon(lat, lon)
   return "DE"
end

get '/photo_locations.json' do
  client = Instagram.client(:access_token => session[:access_token])
  tags = client.tag_search('blacklivesmatter')
  content_type :json
  d = client.tag_recent_media(tags[0].name, {"count" => 1000})
      .select { |n| !n.location.nil? }
      .map { |n| {"loc" => StateFromLatLon(n.location.latitude, n.location.longitude), "img" => n.images.low_resolution.url} }
  d.to_json
  # [{"img" => "http://scontent-b.cdninstagram.com/hphotos-xpa1/t51.2885-15/924100_769271873143514_497356768_a.jpg", "state" => "DE"}, {"img" => "http://scontent-a.cdninstagram.com/hphotos-xaf1/t51.2885-15/10853007_1525507041058609_639556458_a.jpg", "state" => "CA"}].to_json
end

get '/' do
  erb :index
end


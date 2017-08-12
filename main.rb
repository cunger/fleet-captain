require 'sinatra'
require 'sinatra/reloader'

require_relative 'src/file_system'

## Configure Sinatra

configure do
  set :server, 'thin'
end

## Set up file system

@@file_system = FleetCaptain::FileSystem.load

#### Routes ####

# GET '/' => file index

####

get '/' do
  haml :index, :locals => { :files => @@file_system.files }
end

get '/files/:file_name' do |file_name|
  file = @@file_system.find(file_name)
  content_type file.content_type
  file.content
end

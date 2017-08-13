require 'sinatra'
require 'sinatra/reloader'

require_relative 'src/file_system'

## Configure Sinatra

configure do
  set :server, 'thin'
end

enable :sessions

## Set up file system

@@file_system = FleetCaptain::FileSystem.new

#### Routes ####

# GET '/'            => file index
# GET '/files/:name' => show content of a specific file

####

before do
  @context = { :files => @@file_system.files,
               :flash => current_flash_message || 'none' }
end

####

get '/' do
  haml :index
end

get '/files/:file_name' do |file_name|
  file = @@file_system.find(file_name) do
    session[:flash] = 'filenotfound'
    redirect '/'
  end
  content_type file.content_type
  file.content
end

private

def current_flash_message
  session.delete :flash
end

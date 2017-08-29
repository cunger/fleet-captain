require 'sinatra'
require 'sinatra/reloader'

require_relative 'app/file_system'

#### Configure Sinatra ####

configure do
  set :server, 'thin'
end

enable :sessions

#### Set up file system ####

@@file_system = FleetCaptain::FileSystem.new

#### Routes ####

# File index

get '/' do
  @files = @@file_system.files

  haml :index
end

# Show content of a file

get '/files/:file_name' do |file_name|
  file = find file_name

  content_type file.content_type
  file.content
end

# Edit content of a file

get '/files/:file_name/edit' do |file_name|
  @file = find file_name

  haml :edit
end

post '/files/:file_name/edit' do |file_name|
  file = find file_name
  file.content = params['content']

  session[:flash] = "'#{file_name}' was updated."
  redirect '/'
end

## Helpers

helpers do
  def current_flash_message
    session.delete(:flash) || ''
  end
end

## Aux

private

def find(file_name)
  @@file_system.find(file_name) do
    session[:flash] = 'File not found.'
    redirect '/'
  end
end

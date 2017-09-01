require 'sinatra'
require 'sinatra/reloader'

require_relative 'app/file_system'

#### Configure Sinatra ####

configure do
  set :server, 'thin'
end

enable :sessions

#### Set up file system ####

before do
  @file_system = FleetCaptain::FileSystem.new
end

#### Routes ####

# File index

get '/' do
  @files = @file_system.files
  haml :index
end

# Create new file

get '/files/new' do
  haml :create
end

post '/files/new' do
  file_name = params['name']

  if file_name.strip.empty?
    session[:flash] = 'Please enter a name for the document.'
    redirect '/files/new'
  end

  @file_system.create file_name
  session[:flash] = "'#{file_name}' was created."
  redirect '/'
end

# Show content of a file

get '/files/:file_name' do |file_name|
  file = find file_name

  case file.content_type
  when 'text/plain'
    content_type 'text/plain'
    file.content
  else
    haml :layout { file.content }
  end
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

# Delete file

post '/files/:file_name/delete' do |file_name|
  @file_system.delete file_name
  
  session[:flash] = "'#{file_name}' was deleted."
  redirect '/'
end

## Helpers

helpers do
  def current_flash_message
    session.delete(:flash) || ''
  end

  def last_part_of(content_type)
    content_type.split('/')[-1]
  end
end

private

def find(file_name)
  @file_system.find(file_name) do
    session[:flash] = 'File not found.'
    redirect '/'
  end
end

require 'sinatra'
require 'sinatra/reloader'
require 'sysrandom/securerandom'

require_relative 'app/file_system'
require_relative 'app/users'

#### Configure Sinatra ####

configure do
  set :server, 'thin'
end

enable :sessions

set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }

#### Set up file system and users ####

before do
  @file_system = FleetCaptain::FileSystem.new

  @users  = FleetCaptain::Users.new
  @users << FleetCaptain::User.new('test', '1234')

  @user = @users.fetch(session[:user]) { FleetCaptain::GuestUser.new }
end

#### Routes ####

# File index

get '/' do
  @files = @file_system.files
  haml :index
end

# Create new file

get '/files/new' do
  restrict_to_signed_in_user
  haml :create
end

post '/files/new' do
  restrict_to_signed_in_user
  file_name = params['name']
  if file_name.strip.empty?
    redirect_with_message '/files/new', 'Please enter a name for the document.'
  end

  @file_system.create file_name
  redirect_with_message '/', "'#{file_name}' was created."
end

# Show content of a file

get '/files/:file_name' do |file_name|
  file = find file_name

  case file.content_type
  when 'text/plain'
    content_type 'text/plain'
    file.content
  else
    haml(:layout, { layout: false}) { file.content }
  end
end

# Edit content of a file

get '/files/:file_name/edit' do |file_name|
  restrict_to_signed_in_user
  @file = find file_name
  haml :edit
end

post '/files/:file_name/edit' do |file_name|
  restrict_to_signed_in_user
  file = find file_name
  file.content = params['content']

  redirect_with_message '/', "'#{file_name}' was updated."
end

# Delete file

post '/files/:file_name/delete' do |file_name|
  restrict_to_signed_in_user
  @file_system.delete file_name
  redirect_with_message '/', "'#{file_name}' was deleted."
end

# Sign in

get '/user/signin' do
  haml :signin
end

post '/user/signin' do
  begin
    user_name = params['name']
    user_pwd  = params['password']

    @user = @users.fetch user_name
    @user.validate user_pwd

    session[:user] = user_name
    redirect_with_message '/', "Welcome, #{user_name}!"

  rescue FleetCaptain::UserNotFound
    deny_access 'There is no user with this name.'
  rescue FleetCaptain::PasswordNotCorrect
    deny_access 'This password is incorrect.'
  end
end

post '/user/signout' do
  session.delete :user
  redirect_with_message '/', 'You have been signed out.'
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
  @file_system.find(file_name) { redirect_with_message '/', 'File not found.' }
end

def redirect_with_message(path, message)
  session[:flash] = message
  redirect path
end

def restrict_to_signed_in_user
  deny_access unless @user.signed_in?
end

def deny_access(message='You need to be signed in to do this.')
  session[:flash] = message
  halt 403, haml(:signin)
end

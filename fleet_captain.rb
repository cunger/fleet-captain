require 'sinatra'
require 'sinatra/reloader' if development?
require 'sysrandom/securerandom'

require_relative 'app/file_system'
require_relative 'app/file_wrapper'
require_relative 'app/users'


configure do
  enable :sessions
  set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
  set :server, 'thin'
end

before do
  # Set up file system
  dir = settings.environment == :test ? 'test/files' : 'files'
  @file_system = FleetCaptain::FileSystem.new File.join(settings.root, dir)
  # Set up user management
  @users = FleetCaptain::Users.new
  @user = @users.fetch(session[:user]) { FleetCaptain::GuestUser.new }
end

#### Routes ####

# Show file index

get '/' do
  haml :index
end

# Create new file

get '/files/new' do
  restrict_to_signed_in_user

  haml :create
end

post '/files/new' do
  restrict_to_signed_in_user

  begin
    file_name = params['name']
    @file_system.create! file_name
    redirect_with_message '/', "'#{file_name}' was created."

  rescue FleetCaptain::EmptyFileNameError
    redirect_with_message '/files/new', 'Please enter a name for the document.'
  rescue FleetCaptain::UnknownFileExtensionError
    redirect_with_message '/files/new', "Unknown file format \
      (expected one of #{FleetCaptain::FileWrapper.file_extensions.join(', ')})."
  end
end

# Show content of a file

get '/files/:file_name' do |file_name|
  file = fetch file_name
  case file.content_type
  when 'text/html'
    include_in_layout file.content
  else
    content_type 'text/plain'
    file.content
  end
end

# Edit content of a file

get '/files/:file_name/edit' do |file_name|
  restrict_to_signed_in_user

  @file = fetch file_name
  haml :edit
end

post '/files/:file_name/edit' do |file_name|
  restrict_to_signed_in_user

  file = fetch file_name
  file.content = params['content']
  redirect_with_message '/', "'#{file_name}' was updated."
end

# Delete file

post '/files/:file_name/delete' do |file_name|
  restrict_to_signed_in_user

  @file_system.delete! file_name
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

#### Helpers ####

helpers do
  def current_flash_message
    session.delete(:flash) || ''
  end

  def last_part_of(content_type)
    content_type.split('/')[-1]
  end
end

private

def fetch(file_name)
  @file_system.fetch file_name
rescue FleetCaptain::FileNotFoundError
  redirect_with_message '/', 'File not found.'
end

def redirect_with_message(path, message)
  session[:flash] = message
  redirect path
end

def restrict_to_signed_in_user
  deny_access 'You need to be signed in to do this.' unless @user.signed_in?
end

def deny_access(message)
  session[:flash] = message
  halt 403, haml(:signin)
end

def include_in_layout(content)
  haml(:layout, { layout: false}) { content }
end

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'

require_relative '../fleet_captain'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_landing_page
    get_is_ok '/' do
      file_system = FleetCaptain::FileSystem.new
      file_system.files.each do |file|
        assert_includes last_response.body, file.name
      end
    end
  end

  def test_file_routes
    file_system = FleetCaptain::FileSystem.new
    file_system.files.each do |file|
      get_is_ok "/files/#{file.name}"
    end
  end

  def test_non_existing_file
    get_redirects '/files/non-existing-file',
                  destination_includes: 'File not found'
  end

  def test_render_text
    get_is_ok '/files/test.txt' do
      assert_equal 'text/plain;charset=utf-8', last_response['Content-Type']
    end
  end

  def test_render_markdown
    get_is_ok '/files/test.md' do
      assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    end
  end

  def test_edit_file
    random_content = rand(1000).to_s

    get_is_ok  '/files/changes.txt/edit'
    post_is_ok '/files/changes.txt/edit',
               with: { content: random_content },
               destination_includes: "'changes.txt' was updated"
    get_is_ok  '/files/changes.txt' do
      assert_equal random_content, last_response.body.strip
    end
  end

  def test_create_new_file
    get_is_ok  '/files/new'
    post_is_ok '/files/new',
               with: { name: 'new_file' },
               destination_includes: "'new_file' was created"
  end

  def test_delete_file
    # create it
    get_is_ok  '/files/new'
    post_is_ok '/files/new',
               with: { name: 'new_file' }

    # delete it
    post_is_ok '/files/new_file/delete',
               destination_includes: "'new_file' was deleted"

    # check it's gone
    get_redirects '/files/new_file',
                  destination_includes: 'File not found'
  end

  def test_successful_sign_in
    get_is_ok  '/user/signin'
    post_is_ok '/user/signin',
               with: TEST_USER,
               destination_includes: "Signed in as #{TEST_USER[:name]}"
    assert_equal 'gary', session[:user]
  end

  def test_unsuccessful_sign_in
    # with non-existent user name
    post '/user/signin', WRONG_NAME
    assert 403, last_response.status
    assert_includes last_response.body, 'There is no user with this name'
    # with wrond password
    post '/user/signin', WRONG_PASS
    assert 403, last_response.status
    assert_includes last_response.body, 'This password is incorrect'
  end

  def test_sign_out
    post_is_ok '/user/signout',
               destination_includes: 'SIGN IN'
    assert_nil session[:user]
  end

  def test_restricted_access
    file_system = FleetCaptain::FileSystem.new
    file_system.files.each do |file|
      # EDIT and DELETE are not allowed
      get "/files/#{file.name}/edit"
      assert_equal 403, last_response.status
      post "/files/#{file.name}/delete"
      assert_equal 403, last_response.status
    end
    # SHOW is fine
    file_system.files.each do |file|
      get_is_ok "/files/#{file.name}"
    end
  end

  private

  TEST_USER  = { name: 'gary', password: 'anderson' }
  WRONG_NAME = { name: 'none', password: 'anderson' }
  WRONG_PASS = { name: 'gary', password: '1234' }

  def session
    last_request.env['rack.session']
  end

  def get_is_ok(path)
    get path, {}, { 'rack.session' => { user: 'gary' } }
    assert_equal 200, last_response.status
    yield if block_given?
  end

  def get_redirects(path, destination_includes: '')
    get path, {}, { 'rack.session' => { user: 'gary' } }
    assert_equal 302, last_response.status
    get last_response['Location']
    assert_includes last_response.body, destination_includes
  end

  def post_is_ok(path, with: {}, destination_includes: '')
    post path, with, { 'rack.session' => { user: 'gary' } }
    assert_equal 302, last_response.status
    get last_response['Location']
    assert_equal 200, last_response.status
    assert_includes last_response.body, destination_includes
  end
end

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
    check_get_to '/' do
      test_file_system.files.each do |file|
        assert_includes last_response.body, file
      end
    end
  end

  def test_file_routes
    test_file_system.files.each do |file|
      get_is_ok "/files/#{file}"
    end
  end

  def test_non_existing_file
    get_redirects '/files/non-existing-file', and_shows_message: 'File not found.'
  end

  def test_render_text
    check_get_to '/files/test.txt' do
      assert_equal 'text/plain;charset=utf-8', last_response['Content-Type']
    end
  end

  def test_render_markdown
    check_get_to '/files/test.md' do
      assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    end
  end

  def test_edit_file
    random_content = rand(1000).to_s

    get_is_ok '/files/test.txt/edit'
    post_to   '/files/test.txt/edit',
               with: { content: random_content },
               shows_message: "'test.txt' was updated."

    check_get_to '/files/test.txt' do
      assert_equal random_content, last_response.body.strip
    end
  end

  def test_create_new_file
    get_is_ok '/files/new'
    post_to   '/files/new',
              with: { name: 'new_file.txt' },
              shows_message: "'new_file.txt' was created."
    get_is_ok '/files/new_file.txt'
  end

  def test_delete_file
    # create it
    get_is_ok  '/files/new'
    post_is_ok '/files/new', with: { name: 'temp_file.txt' }
    # delete it
    post_to '/files/temp_file.txt/delete',
            shows_message: "'temp_file.txt' was deleted."
    # and check whether it's gone
    get_redirects '/files/temp_file.txt', and_shows_message: 'File not found.'
  end

  def test_successful_sign_in
    get_is_ok '/user/signin'
    post_to   '/user/signin',
              with: TEST_USER,
              shows_message: "Signed in as #{TEST_USER[:name]}"
    assert_equal TEST_USER[:name], session[:user]
  end

  def test_unsuccessful_sign_in
    # with non-existent user name
    post '/user/signin', WRONG_NAME
    assert 403, last_response.status
    assert_includes last_response.body, 'There is no user with this name.'
    # with wrong password
    post '/user/signin', WRONG_PASS
    assert 403, last_response.status
    assert_includes last_response.body, 'This password is incorrect.'
  end

  def test_sign_out
    post_to '/user/signout', shows_message: 'SIGN IN'
    assert_nil session[:user]
  end

  def test_restricted_access
    # for a guest user...
    test_file_system.files.each do |file|
      # ...EDIT and DELETE are not allowed
      get "/files/#{file}/edit"
      assert_equal 403, last_response.status
      post "/files/#{file}/delete"
      assert_equal 403, last_response.status
    end
    # ...but SHOW is fine
    test_file_system.files.each do |file|
      get "/files/#{file}"
      assert last_response.ok?
    end
  end

  private

  TEST_USER  = { name: 'gary', password: 'anderson' }
  WRONG_NAME = { name: 'none', password: 'anderson' }
  WRONG_PASS = { name: 'gary', password: '1234' }

  def session
    last_request.env['rack.session']
  end

  def get_is_ok(path, and_shows_message: nil)
    get path, {}, { 'rack.session' => { user: TEST_USER[:name] } }
    assert last_response.ok?
    assert_equal session[:flash], and_shows_message if and_shows_message
    yield if block_given?
  end
  alias_method :check_get_to, :get_is_ok

  def get_redirects(path, and_shows_message: '')
    get path, {}, { 'rack.session' => { user: TEST_USER[:name] } }
    follow_redirect!
    assert last_response.ok?
    assert_includes last_response.body, and_shows_message
    yield if block_given?
  end

  def post_to(path, with: {}, shows_message: nil)
    post path, with, { 'rack.session' => { user: TEST_USER[:name] } }
    follow_redirect!
    assert last_response.ok?
    assert_includes last_response.body, shows_message if shows_message
  end
  alias_method :post_is_ok, :post_to

  private

  def test_files_dir
    File.dirname(__FILE__) + '/files/'
  end

  def test_file_system
    FleetCaptain::FileSystem.new(test_files_dir)
  end
end

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
    get '/'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']

    # displays all files in the directory
    file_system = FleetCaptain::FileSystem.new
    file_system.files.each do |file|
      assert_includes last_response.body, file.name
    end
  end

  def test_file_routes
    file_system = FleetCaptain::FileSystem.new
    file_system.files.each do |file|
      get "/files/#{file.name}"
      assert_equal 200, last_response.status
    end
  end

  def test_non_existing_file
    get '/files/non-existing-file'
    assert_equal 302, last_response.status

    get last_response['Location']
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'File not found'
  end

  def test_render_markdown
    get '/files/test.md'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
  end

  def test_edit_file
    get '/files/changes.txt/edit'
    assert_equal 200, last_response.status

    # Note: This changes the file in the file system, which is not wanted!
    post '/files/changes.txt/edit', content: 'This file has been changed'
    assert_equal 302, last_response.status
    get last_response['Location']
    assert_equal 200, last_response.status
    assert_includes last_response.body, "'changes.txt' was updated"
  end

  def test_create_new_file
    get '/files/new'
    assert_equal 200, last_response.status

    post '/files/new', name: 'new_file'
    assert_equal 302, last_response.status
    get last_response['Location']
    assert_equal 200, last_response.status
    assert_includes last_response.body, "'new_file' was created"
  end

  def test_delete_file
    # create it
    get '/files/new'
    assert_equal 200, last_response.status
    post '/files/new', name: 'new_file'
    assert_equal 302, last_response.status
    # delete it
    post '/files/new_file/delete'
    assert_equal 302, last_response.status
    get last_response['Location']
    assert_equal 200, last_response.status
    assert_includes last_response.body, "'new_file' was deleted"
    # check it's gone
    get '/files/new_file'
    assert_equal 302, last_response.status
    get last_response['Location']
    assert_includes last_response.body, 'File not found'
  end
end

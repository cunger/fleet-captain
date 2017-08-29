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
    assert_includes last_response.body, 'about.txt'
    assert_includes last_response.body, 'changes.txt'
    assert_includes last_response.body, 'history.txt'
    assert_includes last_response.body, 'example.md'
  end

  def test_text_files
    ['about.txt', 'changes.txt', 'history.txt'].each do |file_name|
      get "/files/#{file_name}"
      assert_equal 200, last_response.status
      assert_equal 'text/plain;charset=utf-8', last_response['Content-Type']
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
    get '/files/example.md'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
  end

  def test_edit_route
    get '/files/changes.txt/edit'
    assert_equal 200, last_response.status

    # Note: This changes the file in the file system, which is not wanted!
    post '/files/changes.txt/edit', content: 'This file has been changed'
    assert_equal 302, last_response.status
    get last_response['Location']
    assert_equal 200, last_response.status
    assert_includes last_response.body, "'changes.txt' was updated"
  end
end

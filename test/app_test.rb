ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'

require_relative '../main'

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
  end

  def test_file_pages
    ['about.txt', 'changes.txt', 'history.txt'].each do |file_name|
      get "/files/#{file_name}"
      assert_equal 200, last_response.status
      assert_equal 'text/plain;charset=utf-8', last_response['Content-Type']
      assert_equal "This is #{file_name}", last_response.body.strip
    end
  end

  def test_non_existing_file_page
    get '/files/non-existing-file'
    assert_equal 302, last_response.status

    get last_response['Location']
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'File not found'
  end
end

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
    assert_equal 404, last_response.status
  end
end

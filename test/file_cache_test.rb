require 'minitest/autorun'
require_relative '../src/file_cache'

class FileCacheTest < Minitest::Test
  def test_caching_about_txt
    about_txt = FleetCaptain::FileCache.create 'files/about.txt'
    assert_equal 'about.txt', about_txt.name
    assert_equal 'files/about.txt', about_txt.path
    assert_equal 'text/plain', about_txt.content_type
    assert_equal 'This is about.txt', about_txt.content.strip
  end
end

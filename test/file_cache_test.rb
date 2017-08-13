require 'minitest/autorun'
require_relative '../src/file_cache'

class FileCacheTest < Minitest::Test

  def test_extension_to_content_type
    [
      ['.txt',  'text/plain'],
      ['.TXT',  'text/plain'],
      ['.htm',  'text/html'],
      ['.html', 'text/html'],
      ['.json', 'application/json'],
      ['.JSON', 'application/json'],
      ['.md',   'text/markdown'],
      ['.tex',  'text/plain']
    ].each do |input, expected|
      assert_equal expected, FleetCaptain::FileCache.send(:to_content_type, input)
    end
  end

  def test_caching_about_txt
    about_txt = FleetCaptain::FileCache.new 'files/about.txt'
    assert_equal 'about.txt', about_txt.name
    assert_equal 'files/about.txt', about_txt.path
    assert_equal 'text/plain', about_txt.content_type
    assert_equal 'This is about.txt', about_txt.content.strip
  end
end

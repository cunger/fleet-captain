require 'minitest/autorun'
require_relative '../app/file_cache'

class FileCacheTest < Minitest::Test
  def test_caching_test_txt
    test_txt = FleetCaptain::FileCache.create 'test/files/test.txt'
    assert_equal 'test.txt', test_txt.name
    assert_equal 'test/files/test.txt', test_txt.path
    assert_equal 'text/plain', test_txt.content_type
    assert_equal 'This is test.txt', test_txt.content.strip
  end

  def test_caching_test_md
    test_md = FleetCaptain::FileCache.create 'test/files/test.md'
    assert_equal 'test.md', test_md.name
    assert_equal 'test/files/test.md', test_md.path
    assert_equal 'text/html', test_md.content_type
    assert test_md.content.start_with?('<h1>Test example</h1>')
    assert test_md.raw_content.start_with?('# Test example')
  end

  def test_changing_content
    changes_txt = FleetCaptain::FileCache.create 'test/files/changes.txt'
    str = "Random number: #{rand(1000)}"
    changes_txt.content = str
    # Change is reflected in content
    assert_equal str, changes_txt.content.strip
    # Change is stored in the file 
    changes_txt = FleetCaptain::FileCache.create 'test/files/changes.txt'
    assert_equal str, changes_txt.content.strip
  end
end

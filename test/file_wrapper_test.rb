ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require_relative '../app/file_wrapper'

class FileWrapperTest < Minitest::Test
  def test_class_based_on_file_extension
    assert_instance_of FleetCaptain::TextFile, FleetCaptain::FileWrapper.create('test.txt')
    assert_instance_of FleetCaptain::TextFile, FleetCaptain::FileWrapper.create('test.TXT')
    assert_instance_of FleetCaptain::HTMLFile, FleetCaptain::FileWrapper.create('test.htm')
    assert_instance_of FleetCaptain::HTMLFile, FleetCaptain::FileWrapper.create('test.html')
    assert_instance_of FleetCaptain::JSONFile, FleetCaptain::FileWrapper.create('test.json')
    assert_instance_of FleetCaptain::MarkdownFile, FleetCaptain::FileWrapper.create('test.md')
  end

  def test_reading_file_content
    name = 'test.txt'
    file = test_file name
    # name is correct
    assert_equal name, file.name
    # and file is not empty
    refute file.content.strip.empty?
  end

  def test_writing_file_content
    file = test_file 'test.txt'
    str  = "Random number: #{rand(1000)}"
    # setting content
    file.content = str
    # reading content
    assert_equal str, file.content.strip
  end

  private

  def test_files_dir
    File.dirname(__FILE__) + '/files/'
  end

  def test_file(name)
    FleetCaptain::FileWrapper.create(test_files_dir + name)
  end
end

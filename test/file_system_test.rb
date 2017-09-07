ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require_relative '../app/file_system'

class FileSystemTest < Minitest::Test
  TEST_FILES = ['test.txt', 'test.md']

  def teardown
    # Clean up file system on disk
    # by removing all temporarily created files
    temp_files = files_on_disk - TEST_FILES
    temp_files.each do |f|
      path = test_files_dir + f
      FileUtils.rm [path] if File.exist? path
    end
  end

  def test_files
    assert_equal files_on_disk.sort, test_file_system.files.sort
  end

  def test_create_and_delete_file
    file_system = test_file_system
    file_name = 'temp.txt'

    file_system.create! file_name

    assert File.exist?(test_files_dir + file_name),
      "The file system was told to create #{file_name}, but it doesn't exist."
    refute_nil file_system.fetch(file_name)

    file_system.delete! file_name

    refute File.exist?(test_files_dir + file_name),
      "The file system was told to delete #{file_name}, but it's still there."
    assert_raises FleetCaptain::FileNotFoundError do
      file_system.fetch file_name
    end
  end

  private

  def test_files_dir
    File.dirname(__FILE__) + '/files/'
  end

  def test_file_system
    FleetCaptain::FileSystem.new(test_files_dir)
  end

  def files_on_disk
    Dir.entries(test_files_dir)
       .reject { |f| f.start_with? '.' }
  end
end

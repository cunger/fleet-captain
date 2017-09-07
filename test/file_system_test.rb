ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require_relative 'test_file_system'

class FileSystemTest < Minitest::Test

  def setup
    @test = test_file_system
  end

  def teardown
    # Clean up test files directory on disk
    # by removing all temporarily created files
    @test.clean_up!
  end

  def test_files
    assert_equal @test.files_on_disk.sort,
                 @test.file_system.files.sort
  end

  def test_create_and_delete_file
    file_name = 'temp.txt'

    @test.file_system.create! file_name

    assert File.exist?(test_files_dir + file_name),
      "The file system was told to create #{file_name}, but it doesn't exist."
    refute_nil @test.file_system.fetch(file_name)

    @test.file_system.delete! file_name

    refute File.exist?(test_files_dir + file_name),
      "The file system was told to delete #{file_name}, but it's still there."
    assert_raises FleetCaptain::FileNotFoundError do
      @test.file_system.fetch(file_name)
    end
  end

  private

  def test_files_dir
    File.dirname(__FILE__) + '/files/'
  end

  def test_file_system
    FleetCaptain::TestFileSystem.new(test_files_dir)
  end
end

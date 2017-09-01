ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require_relative '../app/file_system'

class FileSystemTest < Minitest::Test
  def test_path
    assert_equal 'files',      FleetCaptain::FileSystem.new('files').path
    assert_equal 'test/files', FleetCaptain::FileSystem.new.path
  end

  def test_files
    compare_files 'files'
    compare_files 'test/files'
  end

  def test_create_and_find_file
    file_system = FleetCaptain::FileSystem.new
    # create file
    file_name = 'created.txt'
    file_system.create file_name
    # look at it
    file = file_system.find file_name
    refute_nil file
    assert_equal file_name, file.name
    assert file.content.strip.empty?
  end

  def test_delete_file
    file_system = FleetCaptain::FileSystem.new
    # create file
    file_name = 'temporary.txt'
    file_system.create file_name
    # check it's there
    file = file_system.find file_name
    refute_nil file
    # delete it again
    file_system.delete file_name
    # chec it's not there anymore
    file = file_system.find file_name
    assert_nil file 
  end

  private

  def compare_files(dir)
    files_from_disk = Dir.entries dir
    files_from_capt = FleetCaptain::FileSystem.new(dir).files
    files_from_capt.each do |file|
      assert_includes files_from_disk, file.name
    end
    refute !files_from_disk.empty? && files_from_capt.empty?
  end
end

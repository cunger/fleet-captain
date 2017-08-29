require 'minitest/autorun'
require_relative '../app/file_system'

class FileSystemTest < Minitest::Test
  def test_all_files
    files = FleetCaptain::FileSystem.new.files.map(&:name)
    ['about.txt', 'changes.txt', 'history.txt', 'example.md'].each do |file|
      assert_includes files, file
    end
  end
end

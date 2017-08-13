require 'minitest/autorun'
require_relative '../src/file_system'

class FileSystemTest < Minitest::Test
  def test_all_files
     assert_equal ['about.txt', 'changes.txt', 'history.txt'],
                  FleetCaptain::FileSystem.new.files.map(&:name)
  end
end

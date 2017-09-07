require_relative '../app/file_system'

module FleetCaptain
  class TestFileSystem
    TEST_FILES = ['test.txt', 'test.md']

    attr_reader :file_system

    def initialize(dir)
      @file_system = FleetCaptain::FileSystem.new(dir)
    end

    def clean_up!
      temp_files = files_on_disk - TEST_FILES
      temp_files.each do |f|
        path = @file_system.path + f
        FileUtils.rm [path] if File.exist? path
      end
    end

    def files_on_disk
      Dir.entries(@file_system.path)
         .reject { |f| f.start_with? '.' }
    end
  end
end

require_relative 'file_cache'

module FleetCaptain
  BASEPATH = 'files'
  IGNORE = ['.', '..']

  class FileDoesNotExistError < RuntimeError; end

  class FileSystem
    attr_reader :files

    def initialize
      @files = all_files_in BASEPATH
    end

    def find(basename)
      @files.select { |file| file.name == basename }
            .fetch(0) { raise FileDoesNotExistError }
    end

    private

    def all_files_in(path)
      files = []
      Dir.entries(path).each do |entry|
        next if IGNORE.include?(entry)

        entry = path + '/' + entry

        files << FileCache.new(entry) if File.file?(entry)
        files += all_files_in(entry) if File.directory?(entry)
      end
      files
    end
  end
end
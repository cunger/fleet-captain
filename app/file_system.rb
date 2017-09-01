require_relative 'file_cache'

module FleetCaptain
  IGNORE = ['.', '..']
  BASEPATH = ENV['RACK_ENV'] == 'test' ? 'test/files' : 'files'

  class FileSystem
    attr_reader :path

    def initialize(path=BASEPATH)
      @path = path
    end

    def create(name)
      FileUtils.touch [@path + '/' + name]
    end

    def delete(name)
      FileUtils.rm [@path + '/' + name]
    end

    def find(name)
      files.select { |file| file.name == name }
           .fetch(0) { yield if block_given? }
    end

    def files
      files = []
      Dir.entries(@path).each do |entry|
        next if IGNORE.include?(entry)

        entry = @path + '/' + entry

        files << FileCache.create(entry) if File.file?(entry)
        files += all_files_in(entry) if File.directory?(entry)
      end
      files
    end
  end
end

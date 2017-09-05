require_relative 'file_wrapper'

module FleetCaptain
  class FileNotFoundError < RuntimeError ; end

  class FileSystem
    attr_reader :path

    def initialize(path)
      @path = with_trailing_slash path
    end

    def create(name)
      FileUtils.touch [path + name]
    end

    def delete(name)
      if_file_exists(name) { |file| FileUtils.rm [file] }
    end

    def find(name)
      if_file_exists(name) { |file| FileWrapper.create file }
    end

    def files
      Dir.entries(path)
         .select { |entry| File.file? path+entry }
         .reject { |entry| entry.start_with? '.' }
    end

    private

    def with_trailing_slash(str)
      str.end_with?('/') ? str : str + '/'
    end

    def if_file_exists(name, &block)
      raise FileNotFoundError unless File.exist?(path + name)
      block.call(path + name)
    end
  end
end

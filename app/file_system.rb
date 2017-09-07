require_relative 'file_wrapper'

module FleetCaptain
  class FileNotFoundError < RuntimeError ; end
  class EmptyFileNameError < RuntimeError ; end
  class UnknownFileExtensionError < RuntimeError ; end

  # The FileSystem is responsible for knowing the files in its path,
  # as well as for creating and deleting files.
  # When asked to fetch a particular file, it will wrap it using FileWrapper.
   
  class FileSystem
    attr_reader :path

    def initialize(path)
      @path = with_trailing_slash path
    end

    def create!(name)
      raise EmptyFileNameError if name.strip.empty?
      raise UnknownFileExtensionError unless FileWrapper.knows_extension_of?(name)

      FileUtils.touch [path + name]
    end

    def delete!(name)
      if_file_exists(name) { |file| FileUtils.rm [file] }
    end

    def fetch(name)
      if_file_exists(name) { |file| FileWrapper.wrap file }
    end

    def files
      Dir.entries(path)
         .select { |entry| File.file?(path + entry) }
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

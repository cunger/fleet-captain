module FleetCaptain
  CONTENT_TYPE = { '.txt'  => 'text/plain',
                   '.htm'  => 'text/html',
                   '.html' => 'text/html',
                   '.md'   => 'text/markdown', # de facto, not official
                   '.json' => 'application/json' }

  class FileCache
    attr_reader :name, :path, :content_type, :content

    def initialize(path)
      @path = path
      @name = File.basename(path)
      @content_type = FileCache.to_content_type File.extname(path)
      @content = File.read(path)
    end

    private

    def self.to_content_type(extension)
      CONTENT_TYPE.fetch(extension.downcase, 'text/plain')
    end
  end
end

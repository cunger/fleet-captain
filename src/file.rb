module FleetCaptain
  CONTENT_TYPE = { '.txt'  => 'text/plain',
                   '.htm'  => 'text/html',
                   '.html' => 'text/html' }

  class File
    attr_reader :name, :path, :content_type, :content

    def initialize(path)
      @path = path
      @name = ::File.basename(path)
      @content_type = to_content_type ::File.extname(path)
      @content = ::File.read(path)
    end

    private

    def to_content_type(extension)
      CONTENT_TYPE.fetch(extension, 'text/plain')
    end
  end
end

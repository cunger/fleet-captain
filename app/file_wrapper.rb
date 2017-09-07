require 'redcarpet'

module FleetCaptain

  # The FileWrapper knows about the full path of a file.
  # It is responsible for accessing and updating the content of that file.

  class FileWrapper
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def name
      File.basename path
    end

    def content
      File.read path
    end

    def content=(text)
      File.write path, text
    end
  end

  # There is one subclass of FileWrapper for each known file type.
  # Each subclass is responsible for knowing about the MIME type of the file,
  # and possibly what processing to do in order to render its content.

  class TextFile < FileWrapper
    def content_type
      'text/plain'
    end
  end

  class HTMLFile < FileWrapper
    def content_type
      'text/html'
    end
  end

  class JSONFile < FileWrapper
    def content_type
      'application/json'
    end
  end

  class MarkdownFile < FileWrapper
    def initialize(path)
      @markdown = Redcarpet::Markdown.new Redcarpet::Render::HTML
      super
    end

    def content_type
      'text/html'
    end

    def content
      @markdown.render super
    end
  end

  # FileWrapper also serves as factory for creating instances of
  # the appropriate file type, based on the file's extension.
  
  class FileWrapper
    MAP = { '.txt' => FleetCaptain::TextFile,
             '.md' => FleetCaptain::MarkdownFile,
            '.htm' => FleetCaptain::HTMLFile,
           '.html' => FleetCaptain::HTMLFile,
           '.json' => FleetCaptain::JSONFile }

    def self.wrap(path)
      MAP[extension(path)].send(:new, path)
    end

    def self.file_extensions
      MAP.keys
    end

    def self.knows_extension_of?(name)
      file_extensions.include? extension(name)
    end

    private

    def self.extension(path)
      File.extname(path).downcase
    end
  end
end

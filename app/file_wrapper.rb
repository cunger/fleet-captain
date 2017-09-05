require 'redcarpet'

module FleetCaptain
  class UnknownFileType < RuntimeError ; end

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
      content = File.read path
      @markdown.render content
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

    def self.create(path)
      MAP.fetch(extension(path)) { raise UnknownFileType }
         .send(:new, path)
    end

    private

    def self.extension(path)
      File.extname(path).downcase
    end
  end
end

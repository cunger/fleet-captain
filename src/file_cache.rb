module FleetCaptain

  class FileNotFoundError < RuntimeError; end

  # Basic files, treated as plain text. Used for text files and also
  # serves as fallback for all unknown file extensions.
  class PlainFileCache
    attr_reader :path

    def initialize(path)
      raise FileNotFoundError if !File.exist?(path)

      @path = path
      @raw_content = File.read path
    end

    def name
      File.basename path
    end

    def content_type
      'text/plain'
    end

    def content
      raw_content
    end

    protected

    attr_reader :raw_content
  end

  class HTMLFileCache < PlainFileCache
    def content_type
      'text/html'
    end
  end

  class JSONFileCache < PlainFileCache
    def content_type
      'application/json'
    end
  end

  class MarkdownFileCache < PlainFileCache
    def initialize(path)
      @markdown = Redcarpet::Markdown.new Redcarpet::Render::HTML
      super
    end

    def content_type
      'text/markdown'
    end

    def content
      @markdown.render @raw_content
    end
  end

  # Factory for creating instances of the appropriate file type,
  # based on the file's extension.
  class FileCache
    CLASS = { '.md'   => FleetCaptain::MarkdownFileCache,
              '.htm'  => FleetCaptain::HTMLFileCache,
              '.html' => FleetCaptain::HTMLFileCache,
              '.json' => FleetCaptain::JSONFileCache }

    def self.create(path)
      CLASS.fetch(extension(path), FleetCaptain::PlainFileCache)
           .send(:new, path)
    end

    private

    def self.extension(path)
      File.extname(path).downcase
    end
  end
end

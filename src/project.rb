module Dixi
  class Project

    def initialize( name, version )
      @name = name
      @version = Dixi::Version.new(version)
    end

    attr_reader :name, :version

    def filepath
      Dixi.contents_dir.join(@name, @version.to_s)
    end

    def name
      @name + "/" + @version
    end

    # Create a new Resource for this project
    def resource( entry )
      Dixi::Resource.make( :project => self, :entry => entry )
    end

    def url
      Dixi.url_base.join(@name, @version.to_s)
    end

    def with_version( other_version )
      self.class.new(@name, other_version)
    end

  end
end

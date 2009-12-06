require 'yaml'

module Dixi
  class Resource

    # Example for URL "/rubygame/2.6.2/api/Rubygame/Surface/blit"
    # 
    # project::  Dixi::Project.new("rubygame", "2.6.2")
    # entry::    "api/Rubygame/Surface/blit"
    # 
    def initialize( project, entry )
      @project = project
      @entry   = entry
      @parts   = entry.split('/')
    end

    attr_reader :project, :entry


    def filepath
      Pathname.new(@project.filepath.join(*@parts).to_s + ".yaml")
    end

    def has_content?
      filepath.exist?
    end


    def load
      YAML.load_file( filepath.to_s )
    rescue Errno::ENOENT
      ""
    end

    def save( contents )
      File.open( filepath.to_s, "w+" ) do |f|
        YAML.dump( contents, f )
      end
    end

    def save_raw( contents_str )
      File.open( filepath.to_s, "w+" ) do |f|
        f << contents_str.to_s
      end
    end


    def name
      @project.name + "/" + @entry
    end


    def url( extra="" )
      @project.url.join(@entry).to_s + extra
    end

    def url_read
      url
    end

    def url_submit
      url
    end

    def url_edit
      url ";edit"
    end

  end

end

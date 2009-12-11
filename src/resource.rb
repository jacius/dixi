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

      @content     = nil
      @raw_content = nil
    end

    attr_reader :project, :entry


    def filepath
      Pathname.new(@project.filepath.join(*@parts).to_s + ".yaml")
    end

    def has_content?
      filepath.exist? or (raw_content and not raw_content.empty?)
    rescue NoMethodError
      false
    end


    def raw_content
      @raw_content ||= filepath.read()
    rescue Errno::ENOENT
      ""
    end

    def raw_content=( raw )
      @raw_content = raw
    end

    def content
      @content ||= YAML.load( raw_content )
    end


    def save( options={} )
      c = if options[:raw]
            options[:content] || @raw_content
          else
            YAML.dump( options[:content] || @content )
          end

      filepath.dirname.mkpath
      filepath.open( "w+" ) do |f|
        f << c.to_s
      end

      Dixi::Git.add( filepath )
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
      url "?edit"
    end

  end

end

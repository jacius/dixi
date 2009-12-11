require 'yaml'

module Dixi
  class Resource

    # Example for URL "/rubygame/2.6.2/api/Rubygame/Surface/blit"
    # 
    # project::  Dixi::Project.new("rubygame", "2.6.2")
    # entry::    "api/Rubygame/Surface/blit"
    # 
    def initialize( args={} )

      # Create from another instance. Used for transmuting class.
      if args[:resource]
        other        = args[:resource]
        @project     = other.project
        @entry       = other.entry
        @parts       = @entry.split('/')
        @content     = nil
        @raw_content = other.raw_content

      # Create from a project and entry
      else
        @project     = args[:project]
        @entry       = args[:entry]
        @parts       = @entry.split('/')
        @content     = nil
        @raw_content = nil
      end

      if @project.nil? or @entry.nil?
        raise ArgumentError, "Insufficient resource args: #{args.inspect}"
      end
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


    def template_read
      :read_resource
    end

    def template_edit
      :edit_resource
    end

  end

end

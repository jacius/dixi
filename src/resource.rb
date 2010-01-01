#
#  Copyright 2009 John Croisant
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#  


module Dixi
  class Resource
  end
end

require 'src/classmod_resource'
require 'src/method_resource'

module Dixi
  class Resource

    # All supported resource types, in the order they should be shown
    # to the user as options.
    ALL_TYPES = ["generic resource", "module", "class",
                 "module method", "class method", "instance method"]

    TYPE_SUFFIXES = {
      "module"          => "-m",
      "class"           => "-c",
      "module method"   => "-mm",
      "class method"    => "-cm",
      "instance method" => "-im",
    }

    # Matches strings ending with a type suffix, plus maybe ".yaml".
    # Group 1 will be everything before the type suffix.
    # Group 2 will be the type suffix (including the leading dash).
    # Group 3 will be ".yaml" or nil.
    SUFFIX_REGEXP = /(.*)(-(?:im|cm|mm|c|m))(\.yaml)?$/


    # Returns all existing resources in the project that match the
    # given entry, or an empty Array if no resources match.
    # 
    # If type is specified, only resources of that type (checked by
    # type suffix in the filename) will match. There will always be
    # either zero or one result in this case, because there cannot be
    # more than one resource with the same entry and type.
    # 
    def self.matching( project, entry, type=nil )
      Dixi.logger.info( "Resource.matching( project=#{project.inspect}, " +
                        "entry=#{entry.inspect}, type=#{type.inspect} )" )

      suffix =
        if SUFFIX_REGEXP =~ entry
          Dixi.logger.info( "#{entry} already has suffix: #{$2.inspect}" )
          ""
        else
          TYPE_SUFFIXES[type] || "*"
        end

      suffix += ".yaml" unless entry =~ /\.yaml$/

      pathglob = project.version_dir.join(*entry.split("/")).to_s + suffix
      Dixi.logger.info( "#{entry}'s pathglob is #{pathglob.inspect}" )

      Pathname.glob( pathglob ).collect do |filepath|
        unless filepath.directory?
          Dixi.logger.info( "Found #{filepath}." )

          suf = (SUFFIX_REGEXP =~ filepath.to_s) ? $2 : ""
          make( :project  => project,
                :entry    => entry + suf,
                :type     => type )
        end
      end.compact
    end


    # Create an appropriate resource instance based on the content
    # type. E.g. if type is "module", makes a ModuleResource.
    # If there's no type match, just returns a Resource.
    # 
    def self.make( args={} )
      resource = new( args )

      return resource unless resource.content

      case resource.type
      when /method/i
        return Dixi::MethodResource.new( :resource => resource )
      when /class|module/i
        return Dixi::ClassmodResource.new( :resource => resource )
      else
        return resource
      end
    end


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
        @type        = other.type
        @entry       = other.entry
        @parts       = @entry.split('/')
        @content     = nil
        @raw_content = other.raw_content

      # Create from a project and entry
      else
        @project     = args[:project]
        @type        = args[:type]
        @entry       = args[:entry]
        if @entry =~ SUFFIX_REGEXP
          @entry = $1
          @type  = TYPE_SUFFIXES.invert[$2]
        end
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
      Pathname.new(@project.version_dir.join(*@parts).to_s +
                   type_suffix + ".yaml")
    end

    def has_content?
      filepath.exist? or (not raw_content.empty?)
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
      @content = nil
    end

    def content( options={:rescue => true} )
      require 'yaml'
      @content ||= (YAML.load(raw_content) or {})
    rescue => error
      if options[:rescue]
        {}
      else
        raise error
      end
    end

    def content=( content )
      @content = content
      @raw_content = YAML.dump(content)
    end


    def content_as_yaml
      raw_content
    end


    def save( options={} )
      c = if options[:raw] or @content.nil?
            @raw_content
          else
            require 'yaml'
            YAML.dump( @content )
          end

      filepath.dirname.mkpath
      filepath.open( "w+" ) do |f|
        f << c.to_s
      end

      @project.git_add( filepath )
    end


    def delete
      @project.git_remove( filepath )
    end


    def name
      @project.dirname_and_version + "/" + @entry
    end

    def basename
      @parts[-1]
    end


    def type
      unless @content.nil? or @content.empty?
        @type || content["type"] || "generic resource"
      else
        @type || "generic resource"
      end
    end

    def type=( new_type )
      @type = content["type"] = new_type
    end

    def type_suffix
      if @entry =~ SUFFIX_REGEXP
        "" # already has a suffix
      else
        TYPE_SUFFIXES[type] || ""
      end
    end


    def child( name )
      @project.resource( @entry + "/" + name )
    end


    def url( extra="" )
      e = Rack::Utils.escape(@entry).gsub("%2F","/")
      @project.version_url.join(e).to_s + extra
    end

    def url_read
      url
    end

    def url_read_yaml
      url(".yaml")
    end

    def url_submit
      url
    end

    def url_edit
      url "?edit"
    end

    def url_create( options={} )
      url "?create" + (options[:overwrite] ? "&overwrite=yes" : "")
    end

    def url_delete
      url "?delete"
    end


    def template_read
      :read_resource
    end

    def template_edit
      :edit_resource
    end

    def template_create
      :create_resource
    end

    def template_delete
      :delete_resource
    end


    def inspect
      "#<#{self.class} #{name.inspect}>"
    end

  end

end

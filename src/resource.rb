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


    # Create a Resource from an args hash. The meaningful args are:
    # 
    # :project::  Dixi::Project that this resource belongs to.
    # :type::     The resource's type, e.g. "instance method".
    # :resource:: An existing Resource. Used for transmuting class.
    # :filepath:: Absolute Pathname to the resource's YAML file.
    # :entry::    The resource ID, e.g. "api/Rubygame/Surface/blit-im"
    # 
    # You must provide :project, plus one of :resource, :filepath, or
    # :entry.
    # 
    # :type is optional, and may be ignored if the resource already
    # has a defined type.
    # 
    def initialize( args={} )

      # Create from another instance. Used for transmuting class.
      if args[:resource]
        other         = args[:resource]
        @project      = other.project
        @type         = other.type
        @entry        = other.entry
        @parts        = @entry.split('/')
        @content      = nil
        @yaml_content = other.yaml_content

      # Create from a project and filepath
      elsif args[:filepath]
        @project      = args[:project]
        @filepath     = args[:filepath]
        @type         = args[:type]
        @parts        = @filepath.relative_path_from(@project.version_dir).
                          sub_ext("").to_s.split(File::SEPARATOR)
        @entry        = @parts.join("/")
        if @entry =~ SUFFIX_REGEXP
          @entry = $1
          @type  = TYPE_SUFFIXES.invert[$2]
        end
        @content      = nil
        @yaml_content = nil

      # Create from a project and entry
      else
        @project      = args[:project]
        @type         = args[:type]
        @entry        = args[:entry]
        if @entry =~ SUFFIX_REGEXP
          @entry = $1
          @type  = TYPE_SUFFIXES.invert[$2]
        end
        @parts        = @entry.split('/')
        @content      = nil
        @yaml_content = nil
      end

      if @project.nil? or @entry.nil?
        raise ArgumentError, "Insufficient resource args: #{args.inspect}"
      end
    end

    attr_reader :project, :entry


    def filepath
      @filepath || Pathname.new(@project.version_dir.join(*@parts).to_s +
                                type_suffix + ".yaml")
    end

    def has_content?
      filepath.exist? or (not yaml_content.empty?)
    rescue NoMethodError
      false
    end


    def yaml_content
      @yaml_content ||= filepath.read()
    rescue Errno::ENOENT
      ""
    end

    def yaml_content=( yaml )
      @yaml_content = yaml
      @content = nil
    end

    def content( options={:rescue => true} )
      @content ||= (YAML.load(yaml_content) or {})
    rescue => error
      if options[:rescue]
        {}
      else
        raise error
      end
    end

    def content=( content )
      @content = content
      @yaml_content = YAML.dump(content)
    end


    def save( options={} )
      c = if options[:raw] or @content.nil?
            @yaml_content
          else
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


    # Returns an array of all existing resources which are children of
    # this resource, or [] if there are no children.
    # 
    # A child is a resource contained within this resource. For
    # example, "api/Rubygame/Surface" is a child of "api/Rubygame".
    # 
    def children
      # Generate a pathname for a possible directory corresponding to
      # this resource. E.g. the directory for "api/Rubygame-m" is
      # "api/Rubygame/" (type suffix is discarded).
      dir = @project.version_dir.join(*@parts)

      # No directory means no children.
      return [] unless dir.directory?

      # Create resources for all the YAML files and subdirectories
      # within this resource's directory.
      dir.children.sort.collect { |path|
        entry = path.relative_path_from(@project.version_dir).to_s
        entry = entry.split(File::SEPARATOR).join("/")

        if path.directory?
          # If it's a directory and it doesn't have a matching YAML
          # file, create a generic resource to represent it.
          if @project.matching(entry).empty?
            @project.resource( entry )
          end
        elsif SUFFIX_REGEXP =~ entry.to_s
          @project.resource( entry )
        end
      }.compact
    end


    def url( extra="" )
      e = Rack::Utils.escape(@entry).gsub("%2F","/")
      @project.version_url.mp_join(e).to_s + type_suffix + extra
    end

    def url_read
      e = Rack::Utils.escape(@entry).gsub("%2F","/")
      @project.version_url.mp_join(e).to_s
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

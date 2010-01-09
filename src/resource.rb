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

    # Same as SUFFIX_REGEXP, but the type suffix is optional.
    OPT_SUFFIX_REGEXP = /(.*)(-(?:im|cm|mm|c|m))?(\.yaml)?$/


    # Takes a resource ID with no type, and returns all existing
    # resources in the project that match that ID, or an empty Array
    # if no resources match. For example, if the ID was "api/foo", it
    # would match both "api/foo-cm" and "api/foo-im".
    # 
    # If id has a type suffix or .yaml file extension, they are ignored.
    # 
    def self.matching( project, id )
      Dixi.logger.info( "Resource.matching( " +
                        "project=#{project.inspect}, " +
                        "id=#{id.inspect} )" )

      # Ignore type suffix or .yaml file extension
      if SUFFIX_REGEXP =~ id
        id = $1
      end

      pathglob = project.version_dir.join( *id.split("/") ).to_s + "-*"

      Dixi.logger.info( "#{id}'s pathglob is #{pathglob.inspect}" )

      Pathname.glob( pathglob ).collect { |filepath|
        unless filepath.directory?
          Dixi.logger.info( "Found #{filepath}." )
          path = filepath.relative_path_from( project.version_dir )
          m = OPT_SUFFIX_REGEXP.match( path.to_s )
          project.resource( m[1]+m[2].to_s )
        end
      }.compact
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
    # :id::       The resource ID, e.g. "api/Rubygame/Surface/blit-im"
    #             Partial (untyped) IDs are not supported. So
    #             "api/Rubygame/Surface/blit" is WRONG. Use
    #             Resource.find if you have a partial ID.
    # 
    # You must provide :project, plus either :resource or :id.
    # 
    # :type is optional, and may be ignored if the resource already
    # has a defined type.
    # 
    def initialize( args={} )

      # Create from another instance. Used for transmuting class.
      if args[:resource]
        other    = args[:resource]
        @project = other.project
        @type    = other.type
        @id      = other.id
        @content = other.content(:load => false)
        @yaml    = other.yaml_content(:load => false)

      # Create from a project and id
      else
        @project = args[:project]
        @type    = args[:type]
        @id      = args[:id]
        if SUFFIX_REGEXP =~ @id
          suffix = $2
          @id    = $1 + suffix
          @type  = TYPE_SUFFIXES.invert[suffix]
        end
        @content = nil
        @yaml    = nil
      end

      if @project.nil? or @id.nil?
        raise ArgumentError, "Insufficient resource args: #{args.inspect}"
      end
    end

    attr_reader :project, :id


    def inspect
      "#<#{self.class} #{name.inspect}>"
    end


    def exist?
      filepath.exist?
    end

    def filepath
      @filepath || 
        @project.version_dir.join(*split_id(@id)).mp_append(".yaml")
    end

    def has_content?
      exist? or (not yaml_content.empty?)
    rescue NoMethodError
      false
    end


    def yaml_content( options={:load => true} )
      options = {:load => true}.merge( options )

      if options[:load]
        @yaml ||= filepath.read()
      else
        @yaml
      end
    rescue Errno::ENOENT
      ""
    end

    def yaml_content=( yaml )
      @yaml = yaml
      @content = nil
    end


    def content( options={:rescue => true, :load => true} )
      options = {:rescue => true, :load => true}.merge( options )

      if options[:load]
        @content ||= (YAML.load(yaml_content) or {})
      else
        @content
      end
    rescue => error
      if options[:rescue]
        {}
      else
        raise error
      end
    end

    def content=( content )
      @content = content
      @yaml = YAML.dump(content)
    end


    def save( options={} )
      c = if options[:raw] or @content.nil?
            @yaml
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
      @project.dirname_and_version + "/" + @id
    end

    def basename
      split_id(id_no_suffix)[-1]
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


    def child( name )
      @project.resource( id_no_suffix + "/" + name )
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
      dir = @project.version_dir.join( *split_id(id_no_suffix) )

      # No directory means no children.
      return [] unless dir.directory?

      # Create resources for all the YAML files and subdirectories
      # within this resource's directory.
      dir.children.sort.collect { |path|
        child_id = path.relative_path_from(@project.version_dir).to_s
        child_id = child_id.split(File::SEPARATOR).join("/")

        if path.directory?
          # If it's a directory and it doesn't have a matching YAML
          # file, create a generic resource to represent it.
          if @project.matching( child_id ).empty?
            @project.resource( child_id )
          end
        elsif SUFFIX_REGEXP =~ child_id.to_s
          @project.resource( child_id )
        end
      }.compact
    end


    #--
    # URLS
    #++

    def url( extra="" )
      e = Rack::Utils.escape(@id).gsub("%2F","/")
      @project.version_url.mp_join(e).to_s + extra
    end

    def url_read
      e = Rack::Utils.escape(id_no_suffix).gsub("%2F","/")
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


    #--
    # TEMPLATES
    #++

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


    private

    def split_id( id )
      id.split("/")
    end

    def id_no_suffix
      if SUFFIX_REGEXP =~ @id
        $1
      else
        @id
      end
    end


  end

end

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


require 'yaml'

module Dixi
  class Resource
  end
end

require 'src/classmod_resource'
require 'src/method_resource'

module Dixi
  class Resource

    # Create an appropriate resource instance based on the content
    # type. E.g. if type is "module", makes a ModuleResource.
    # If there's no type match, just returns a Resource.
    # 
    def self.make( args={} )
      resource = new( args )

      return resource unless resource.content

      case resource.content["type"]
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
      Pathname.new(@project.version_dir.join(*@parts).to_s + ".yaml")
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
    end

    def content
      @content ||= YAML.load( raw_content )
    rescue
      {}
    end

    def content_as_yaml
      raw_content
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

      @project.git_add( filepath )
    end


    def name
      @project.name_and_version + "/" + @entry
    end


    def url( extra="" )
      @project.url.join(@entry).to_s + extra
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


    def template_read
      :read_resource
    end

    def template_edit
      :edit_resource
    end

  end

end

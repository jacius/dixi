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

  # Resource for Classes and Modules.
  class ClassmodResource < Dixi::Resource

    def initialize( args )
      super
      @name = args[:name]
    end

    def type
      @type || content["type"] || "class/module"
    end

    def name
      @name || content["name"] || super
    end

    def base
      if content["base"]
        construct_classmod( content["base"] )
      end
    end

    def includes
      if content["includes"]
        content["includes"].collect{ |m| construct_classmod( m ) }
      else
        []
      end
    end

    def constants
      content["constants"].collect{ |c|
        { "name"  => c["name"]  || "",
          "value" => c["value"] || "",
          "info"  => c["info"]  || "",
        }
      }
    rescue
      []
    end

    def cmethods
      if content["cmethods"]
        content["cmethods"].collect{ |m| construct_method( m ) }        
      else
        []
      end
    end

    def imethods
      if content["imethods"]
        content["imethods"].collect{ |m| construct_method( m ) }        
      else
        []
      end
    end

    def attributes
      require 'src/attribute'
      content["attributes"].collect{ |attr| Dixi::Attribute.new(attr) }
    rescue
      []
    end

    def synopsis
      content["synopsis"] || ""
    end

    def details
      content["details"] || ""
    end


    def index_dump
      hash = super
      hash[id].merge!( "synopsis" => synopsis ) unless synopsis.empty?
      hash
    end


    def template_read( ivars={} )
      Dixi::Views::ReadClassmod.new( {:resource => self}.merge(ivars) )
    end


    private

    def construct_classmod( name )
      id = "api/" + name.split(/\/|::|\.|#/).join("/")
      Dixi::ClassmodResource.new( :project => @project,
                                  :id => id,
                                  :name => name )
    end

    def construct_method( name )
      id = "api/" + name.split(/\/|::|\.|#/).join("/")
      Dixi::MethodResource.new( :project => @project,
                                :id => id,
                                :name => name )
    end

  end

end

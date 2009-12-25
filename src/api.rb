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
  class API

    def initialize( project )
      @project = project
    end

    attr_reader :project

    def dir
      @project.version_dir.join("api")
    end

    def url
      @project.version_url.join("api")
    end

    def entry( entry )
      Dixi::Resource.make( :project => @project,
                           :entry => "api/"+entry )
    end

    # Returns a Hash "tree" of existing API resources in this project
    # version.
    #
    def tree
      t = Dixi::Utils.ls_r( dir ) { |path|
        tree_process_path( path )
      }
      t[ t.keys[0] ] or {}
    end

    # Do the heavy lifting for #tree. Each path is converted
    # based on the following rules:
    # 
    # 1. If it's a directory, make a ClassmodResource.
    # 
    # 2. If it's a YAML file with a matching directory (e.g.
    #    Surface.yaml matches Surface), discard it (return nil)
    #    because it would be a childless duplicate of #1
    # 
    # 3. If it's a YAML file without a matching directory, make a
    #    Resource. It might become a ClassmodResource or a
    #    MethodResource if its contents indicate a type.
    # 
    # 4. All other paths are discarded (return nil).
    # 
    def tree_process_path( path )
      rel_path = path.relative_path_from( dir )

      # Directory
      if path.directory?
        # Make a ClassmodResource for this directory
        entry( rel_path.to_s.split(File::SEPARATOR).join("/") )

      # YAML file
      elsif /(.+)\.yaml$/.match( rel_path.to_s )
        e = $1.split(File::SEPARATOR).join("/")        

        # Only make a resource if there is no directory matching this
        # file. E.g. For Surface.yaml, there is no Surface dir.
        unless Pathname.new( path.to_s.sub(".yaml","") ).directory?
          entry( e )
        end
      end
    end

    private :tree_process_path

  end
end

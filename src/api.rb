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
  class API < Resource

    def initialize( project )
      @project = project
      @id = @parts = "api"
      @yaml_content = @content = nil
    end

    attr_reader :project

    def name
      @project.name
    end

    def children
      @project.index.find_all{ |entry|
        entry.id =~ Regexp.new("^api/[^/]+$")
      }.collect{ |entry|
        entry.resource
      }
    end

    def dir
      @project.version_dir.mp_join("api")
    end

    def url
      @project.version_url.mp_join("api")
    end

    def type
      "api"
    end

    def type_suffix
      ""
    end

  end
end

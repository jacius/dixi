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
      content["type"] || "class/module"
    end

    def name
      @name || content["name"] || ""
    end

    def base
      content["base"] || nil
    end

    def includes
      content["includes"] || []
    end

    def constants
      content["constants"] || []
    end

    def cmethods
      content["cmethods"] || []
    end

    def imethods
      content["imethods"] || []
    end

    def synopsis
      content["synopsis"] || ""
    end

    def details
      content["details"] || ""
    end


    def template_read
      :read_classmod
    end

  end

end

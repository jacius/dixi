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


require 'src/method_arg'

module Dixi

  class MethodResource < Dixi::Resource

    def initialize( args )
      super
      @name = args[:name]
    end

    def type
      @type || content["type"] || "method"
    end

    def name
      @name || content["name"] || super
    end

    def base
      content["base"] || ""
    end

    def args
      @args ||= (content["args"] or []).collect{ |arg|
        Dixi::MethodArg.new(self, arg)
      }
    end

    def aliases
      content["aliases"] || []
    end

    def synopsis
      content["synopsis"] || ""
    end

    def details
      content["details"] || ""
    end

    def visibility
      content["visibility"] || "public"
    end


    def template_read
      :read_method
    end

  end

end

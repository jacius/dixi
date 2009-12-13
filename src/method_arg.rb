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

  class MethodArg

    def initialize( method, content )
      @method = method
      @content = content
    end

    attr_reader :method


    def name
      @content["name"]
    end


    def info
      @content["info"] || ""
    end

    def has_info?
      info and not info.empty?
    rescue NoMethodError
      false
    end


    def type
      @content["type"] || ""
    end

    def has_type?
      type and not type.empty?
    rescue NoMethodError
      false
    end


    def default
      @content["default"] || ""
    end

    def has_default?
      default and not default.empty?
    rescue NoMethodError
      false
    end


    def mustache_hash
      return {
        :arg_name => name,
        :arg_info => info,
        :arg_has_info => has_info?,
        :arg_type => type,
        :arg_has_type => has_type?,
        :arg_default => default,
        :arg_has_default => has_default?,
      }
    end

  end

end

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

  # Represents a Classmod attribute
  class Attribute

    def initialize( hash )
      @hash = hash
    end


    def name
      @hash["name"] || ""
    end


    def read?
      true if @hash["read"]
    end

    def write?
      true if @hash["write"]
    end

    # Returns "R", "W", "RW", or "" depending on read/write status.
    def rw
      [read? && "R", write? && "W"].compact.join
    end


    def has_info?
      not info.empty?
    end

    def info
      @hash["info"] || ""
    end


    def has_type?
      not type.empty?
    end

    def type
      @hash["type"] || ""
    end


    def has_default?
      not default.empty?
    end

    def default
      @hash["default"] || ""
    end

  end

end

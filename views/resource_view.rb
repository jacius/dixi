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
  module Views

    # Base class for all Resource views.
    class ResourceView < Mustache

      def has_content
        @resource.has_content?
      end

      def no_content
        !has_content
      end

      def content
        @resource.content
      end

      def raw_content
        @resource.raw_content
      end


      def name
        @resource.name
      end

      def type
        @resource.type
      end

      def type_capitalized
        type.capitalize
      end


      def file
        @resource.filepath
      end


      def url_edit
        @resource.url_edit
      end

      def url_read
        @resource.url_read
      end

      def url_submit
        @resource.url_submit
      end


      def kramdown( str )
        require 'kramdown'
        Kramdown::Document.new( str ).to_html
      end

    end

  end
end

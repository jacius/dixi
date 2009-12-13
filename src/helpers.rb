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
  module Helpers

    module ResourceViews

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


      def resource_name
        @resource.name
      end

      def resource_type
        @resource.type
      end

      def resource_type_capitalized
        resource_type.capitalize
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
        Kramdown::Document.new( str ).to_html
      end

    end



    module ModuleViews
      include Dixi::Helpers::ResourceViews

      def resource_type
        @resource.type
      end


      def has_includes
        not @resource.includes.empty?
      end

      def includes
        @resource.includes
      end


      def has_constants
        not @resource.constants.empty?
      end

      def constants
        @resource.constants
      end


      def has_synopsis
        not @resource.synopsis.empty?
      end

      def no_synopsis
        not has_synopsis
      end

      def synopsis
        kramdown @resource.synopsis
      end


      def has_details
        not @resource.details.empty?
      end

      def no_details
        not has_details
      end

      def details
        kramdown @resource.details
      end


      def has_cmethods
        not @resource.cmethods.empty?
      end

      def cmethods
        @resource.cmethods.map { |m| {:name => m} }
      end


      def has_imethods
        not @resource.imethods.empty?
      end

      def imethods
        @resource.imethods.map { |m| {:name => m} }
      end

    end



    module ClassViews
      include Dixi::Helpers::ModuleViews

      def has_base
        not @resource.base.nil?
      end

      def base
        @resource.base
      end

    end

  end


end

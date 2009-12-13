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

    class ReadModule < Mustache
      include Dixi::Helpers::ResourceViews


      def is_module
        resource_type =~ /module/i
      end

      def is_class
        resource_type =~ /class/i
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


      def has_base
        not @resource.base.nil?
      end

      def base
        @resource.base
      end

    end

  end
end

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


require 'views/resource_view.rb'

module Dixi
  module Views

    class ReadClassmod < ResourceView

      def is_module
        type =~ /module/i
      end

      def is_class
        type =~ /class/i
      end


      def has_includes
        not @resource.includes.empty?
      end

      def includes
        @resource.includes.to_enum(:each_with_index).map { |inc,index|
          { :name => inc, :index => index }
        }
      end


      def has_constants
        not @resource.constants.empty?
      end

      def constants
        @resource.constants.to_enum(:each_with_index).map { |const,index|
          { :name => const, :index => index }
        }
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

      def raw_synopsis
        @resource.synopsis
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

      def raw_details
        @resource.details
      end


      def has_cmethods
        not @resource.cmethods.empty?
      end

      def cmethods
        @resource.cmethods.to_enum(:each_with_index).map { |m,index|
          { :name => m.name, :index => index }
        }
      end


      def has_imethods
        not @resource.imethods.empty?
      end

      def imethods
        @resource.imethods.to_enum(:each_with_index).map { |m,index|
          { :name => m.name, :index => index }
        }
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

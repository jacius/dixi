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
require 'views/api_tree_view'

module Dixi
  module Views

    class ReadProject < ResourceView
      include Dixi::Views::APITreeView

      def name
        @project.name
      end

      def url
        @project.url
      end

      def url_edit
        @project.url_edit
      end


      def has_details
        not @project.details.empty?
      end

      def details
        kramdown( @project.details )
      end


      def version
        @project.version.to_s
      end

      def has_version
        not version.empty?
      end

      def latest_version
        v = @project.latest_version
        { :version => v.to_s,
          :url => @project.at_version(v).version_url }
      end

      def old_versions_descending
        all_versions_descending[1..-1]
      end

      def all_versions_descending
        @project.all_versions.collect { |v|
          { :version => v.to_s,
            :url => @project.at_version(v).version_url }
        }.reverse
      end


      def has_api_tree
        not @project.api.children.empty?
      end

      def api_tree_html
        @project.api.children.collect{ |child|
          htmlify_api_tree( child )
        }.join("\n")
      end
    end

  end
end

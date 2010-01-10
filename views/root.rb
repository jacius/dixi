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


require 'views/api_tree_view'

module Dixi
  module Views

    class Root < Mustache
      include Dixi::Views::APITreeView

      def has_projects
        not Dixi.projects.empty?
      end

      def projects_hashed
        Dixi.projects.collect { |project|
          children = project.api.children
          children_html = children.collect{ |child|
            htmlify_api_tree( child )
          }.join("\n")

          { :name => project.name,
            :url  => project.url,
            :has_synopsis => (not project.synopsis.empty?),
            :synopsis  => project.synopsis,
            :latest_version => project.version,
            :latest_url => project.version_url,
            :latest_has_tree => (not children.empty?),
            :latest_tree_html => children_html,
          }
        }
      end

    end

  end
end

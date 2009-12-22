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

    class ReadProject < Mustache
      include Dixi::Views::APITreeView

      def name
        @project.name
      end

      def version
        @project.version.to_s
      end

      def has_version
        not version.empty?
      end

      def has_api_tree
        not api_tree.empty?
      end

      def api_tree
        @api_tree ||= @project.api_tree
      end

      def api_tree_html
        htmlify_api_tree( api_tree )
      end

    end

  end
end

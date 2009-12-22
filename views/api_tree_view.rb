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
    module APITreeView

      def htmlify_api_tree( api_tree, maxdepth=10 )
        walk_api_tree( api_tree, maxdepth ).join("")
      end

      private

      def walk_api_tree( tree, maxdepth )
        return [] if tree.empty? or maxdepth <= 0
        render = tree.collect{ |res,children|
          children = if children.nil?
                       []
                     else 
                       walk_api_tree(children, maxdepth - 1)
                     end
          ["<li><a href=\"#{res.url}\">#{res.basename}</a>"] +
            [(res.type.empty? ? "" : " (#{res.type})")] +
            children + 
            ["</li>\n"]
        }.flatten
        ["\n<ul>\n"] + render + ["</ul>\n"]
      end

    end
  end
end

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

    class ReadProject < Mustache

      def name
        @project.name
      end

      def has_tree
        not api_tree.empty?
      end

      def api_tree
        @api_tree ||= walk_tree(@project.api_tree, 5)
        require 'pp'
        puts @api_tree.pretty_inspect
        @api_tree
      end

      private

      def walk_tree( tree, depth = 10 )
        tree.collect{ |k,v|
          children = if v.nil? or depth <= 0
                       []
                     else 
                       walk_tree(v, depth - 1)
                     end
          { :name         => k.name,
            :url          => k.url_read,
            :has_children => (not children.empty?),
            :children     => children,
          }
        }
      end

    end

  end
end

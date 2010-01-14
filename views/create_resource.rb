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

    class CreateResource < ResourceView

      def parent
        @parent.name
      end

      def overwrite
        @overwrite
      end

      def name
        @name || ""
      end

      def type
        ""
      end

      def content
        @content || ""
      end

      def existing_url_read
        @existing.url_read
      end

      def existing_name
        @existing.name
      end

      def url_submit
        url = @parent.url_submit
        if overwrite
          url += "?overwrite=yes"
        end
        url
      end
      
      def url_read
        @parent.url_read
      end

      def submit_verb
        overwrite ? "Overwrite" : "Save"
      end
      
    end

  end
end

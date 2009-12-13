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
  class Project

    def initialize( name, version )
      @name = name
      @version = Dixi::Version.new(version)
    end

    attr_reader :name, :version

    def filepath
      Dixi.contents_dir.join(@name, @version.to_s)
    end

    def name
      @name + "/" + @version
    end

    # Create a new Resource for this project
    def resource( entry )
      Dixi::Resource.make( :project => self, :entry => entry )
    end

    def url
      Dixi.url_base.join(@name, @version.to_s)
    end

    def with_version( other_version )
      self.class.new(@name, other_version)
    end

  end
end

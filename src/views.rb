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

    # Base class for all views.
    class View
      include Sinatra::Helpers

      def initialize( ivars={} )
        ivars.each do |name, value|
          # Make sure it's a symbol starting with one @.
          name = "@#{name}".sub(/^@+/,"@").intern
          instance_variable_set( name, value )
        end
      end

      def render
        haml( template_file.read )
      end

      private

      def haml( template_contents )
        require 'haml'
        ::Haml::Engine.new( template_contents,
                            :filename => template_file.to_s
                            ).render( self )
      end

      def template_file( extension=".haml" )
        Dixi.template_dir.mp_join("#{template_name}#{extension}")
      end

      def template_name
        underscorized_classname.intern
      end

      # Returns an "underscorize" version of the class name
      # (a la ActiveSupport).
      # 
      # E.g. "Dixi::Views::CreateResource" -> "create_resource"
      # 
      def underscorized_classname
        self.class.name.split("::").last.
          gsub( /([A-Z]+)([A-Z][a-z])/, '\1_\2' ).
          gsub( /([a-z\d])([A-Z])/,     '\1_\2' ).downcase
      end

    end


    autoload :ResourceView,      'views/resource_view'
    autoload :CreateResource,    'views/create_resource'
    autoload :DeleteResource,    'views/delete_resource'
    autoload :EditResource,      'views/edit_resource'
    autoload :ReadResource,      'views/read_resource'
    autoload :ReadClassmod,      'views/read_classmod'
    autoload :ReadMethod,        'views/read_method'
    autoload :ReadProject,       'views/read_project'
    autoload :ReadVersion,       'views/read_version'
    autoload :Root,              'views/root'
    autoload :APITreeView,       'views/api_tree_view'

  end
end

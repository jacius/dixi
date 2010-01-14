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
          { :name => inc.name, :url => inc.url_read, :index => index }
        }
      end


      def has_constants
        not @resource.constants.empty?
      end

      def constants
        @resource.constants.to_enum(:each_with_index).collect { |const,index|
          { :name      => const["name"],
            :has_value => (not const["value"].empty?),
            :value     => const["value"],
            :has_info  => (not const["info"].empty?),
            :info      => kramdown( const["info"] ),
            :index     => index,
          }
        }
      end


      def has_synopsis
        not (@resource.synopsis.empty? and @resource.details.empty?)
      end

      def no_synopsis
        not has_synopsis
      end

      def synopsis
        if (not @resource.synopsis.empty?)
          kramdown( @resource.synopsis )
        elsif (not @resource.details.empty?)
          kramdown( Dixi::Utils.snip(@resource.details, 300) +
                    " ([Continued...](#{@resource.url_read+'#details'}))" )
        else
          ""
        end
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
        hashify_methods(@resource.cmethods)
      end


      def has_imethods
        not @resource.imethods.empty?
      end

      def imethods
        hashify_methods(@resource.imethods)
      end


      def has_attributes
        not attributes.empty?
      end

      def attributes
        @attributes = @resource.attributes.collect{ |attr|
          { :name        => attr.name,
            :read        => attr.read?,
            :write       => attr.write?,
            :rw          => attr.rw,
            :has_rw      => (not attr.rw.empty?),
            :type        => attr.type,
            :has_type    => attr.has_type?,
            :default     => attr.default,
            :has_default => attr.has_default?,
            :info        => kramdown( attr.info ),
            :has_info    => attr.has_info?,
          }
        }
      end


      def has_base
        not @resource.base.nil?
      end

      def base
        b = @resource.base
        if b
          { :name => b.name, :url => b.url_read }
        end
      end


      private

      def hashify_methods( methods )
        methods.to_enum(:each_with_index).map { |m,index|
          { :name => m.name, :url => m.url_read, :index => index }
        }
      end

    end

  end
end

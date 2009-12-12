module Dixi
  module Views

    class ReadMethod < Mustache
      include Dixi::Helpers::ResourceViews


      def is_class_method
        resource_type =~ /class method/i
      end

      def is_module_method
        resource_type =~ /module method/i
      end

      def is_instance_method
        resource_type =~ /instance method/i
      end


      def base
        @resource.base
      end

      def has_base
        not @resource.base.nil?
      end


      def args
        @resource.args.collect { |arg| arg.mustache_hash }
      end

      def has_args
        not @resource.args.empty?
      end


      def aliases
        @resource.aliases.collect{ |a|
          { :alias_name => a }
        }
      end

      def has_aliases
        not @resource.aliases.empty?
      end


      def synopsis
        @resource.synopsis
      end

      def has_synopsis
        not @resource.synopsis.empty?
      end

      def no_synopsis
        not has_synopsis
      end


      def details
        kramdown @resource.details
      end

      def has_details
        not @resource.details.empty?
      end

      def no_details
        not has_details
      end

    end

  end
end

module Dixi
  module Helpers

    module ResourceViews

      def has_content
        @resource.has_content?
      end

      def no_content
        !has_content
      end

      def content
        @resource.load
      end

      def raw_content
        @resource.load(:raw => true)
      end


      def resource_name
        @resource.name
      end

      def file
        @resource.filepath
      end


      def url_edit
        @resource.url_edit
      end

      def url_read
        @resource.url_read
      end

      def url_submit
        @resource.url_submit
      end

    end

  end
end

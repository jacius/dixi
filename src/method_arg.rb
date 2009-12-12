
module Dixi

  class MethodArg

    def initialize( method, content )
      @method = method
      @content = content
    end

    attr_reader :method


    def name
      @content["name"]
    end


    def info
      @content["info"] || ""
    end

    def has_info?
      info and not info.empty?
    rescue NoMethodError
      false
    end


    def type
      @content["type"] || ""
    end

    def has_type?
      type and not type.empty?
    rescue NoMethodError
      false
    end


    def default
      @content["default"] || ""
    end

    def has_default?
      default and not default.empty?
    rescue NoMethodError
      false
    end


    def mustache_hash
      return {
        :arg_name => name,
        :arg_info => info,
        :arg_has_info => has_info?,
        :arg_type => type,
        :arg_has_type => has_type?,
        :arg_default => default,
        :arg_has_default => has_default?,
      }
    end

  end

end

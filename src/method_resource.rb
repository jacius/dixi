require 'src/method_arg'

module Dixi

  class MethodResource < Dixi::Resource

    def type
      content["type"] || ""
    end

    def name
      content["name"] || ""
    end

    def base
      content["base"] || ""
    end

    def args
      @args ||= (content["args"] or []).collect{ |arg|
        Dixi::MethodArg.new(self, arg)
      }
    end

    def aliases
      content["aliases"] || []
    end

    def synopsis
      content["synopsis"] || ""
    end

    def details
      content["details"] || ""
    end


    def template_read
      :read_method
    end

  end

end

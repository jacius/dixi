
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
      content["args"] || []
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

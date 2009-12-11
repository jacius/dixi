
module Dixi

  class ModuleResource < Dixi::Resource

    def type
      "module"
    end

    def name
      content["name"] || ""
    end

    def includes
      content["includes"] || []
    end

    def constants
      content["constants"] || []
    end

    def cmethods
      content["cmethods"] || []
    end

    def imethods
      content["imethods"] || []
    end

    def synopsis
      content["synopsis"] || ""
    end

    def details
      content["details"] || ""
    end

  end

end

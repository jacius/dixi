require 'src/module_resource'


module Dixi

  class ClassResource < Dixi::ModuleResource

    def base
      content["base"] || nil
    end

    def template_read
      :read_class
    end

  end

end

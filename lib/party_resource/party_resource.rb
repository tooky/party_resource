module PartyResource

  module ClassMethods
    include MethodDefine

    def connect(name, options={})
      level = options.delete(:on)
      options = {:as => self}.merge(options)
      route = Route.new(options)

      define_method_on(level, name) do |*args|
        route.call(self, *args)
      end
    end

    def property(*names)
      options = names.pop if names.last.is_a?(Hash)
      names.each do |name|
        attr_reader name
      end
    end
  end

  module ParameterValues

    def parameter_values(list)
      list.inject({}) do |out, var|
        begin
          out[var] = send(var)
        rescue
          raise MissingParameter.new(var, self)
        end
        out
      end
    end

  end

  def self.included(klass)
    klass.extend(ClassMethods)
    klass.extend(ParameterValues)
    klass.send(:include, ParameterValues)
  end
end

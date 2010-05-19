module PartyResource

  include MethodDefine

  def connect(name, options={})
    level = options.delete(:on)
    options = {:as => self}.merge(options)
    route = Route.new(options)

    define_method_on(level, name) do |*args|
      route.call(self, *args)
    end
  end

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

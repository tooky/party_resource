module PartyResource

  include MethodDefine

  def connect(name, options={})
    level = options.delete(:on)
    route = Route.new(options)

    define_method_on(level, name) do |*args|
      route.call(self, *args)
    end
  end

end

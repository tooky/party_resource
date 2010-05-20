class TestBaseClass
  attr :args

  def initialize(args={})
    @args = args
  end

  def method_missing(name, *params)
    return args[name] if params.empty? && args.has_key?(name)
    super
  end

  def ==(other)
    self.class == other.class && args == other.args
  end
end


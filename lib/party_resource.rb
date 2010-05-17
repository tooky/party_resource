module PartyResource

  def connect(name, options={})
    level = options.delete(:on)
    connection = Connection.new(options)

    define_method_on(level, name) do |*args|
      connection.call(self, *args)
    end
  end

  private
  def define_meta_method(name, &blk)
    (class << self; self; end).instance_eval { define_method name, &blk }
  end

  def define_method_on(level, name, &block)
    creator = level == :instance ? :define_method : :define_meta_method
    send(creator, name, &block)
  end

  class Connection
    def initialize(options = {})
    end
  end

end

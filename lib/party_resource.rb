module PartyResource

  def connect(name, options={})
    level = options.delete(:on)
    connection = Connection.new(options)

    if level == :instance

      define_method(name) do |*args|
        connection.call(self, *args)
      end
    else
      meta_def(name) do |*args|
        connection.call(self, *args)
      end

    end
  end

  private
  def meta_def name, &blk
    (class << self; self; end).instance_eval { define_method name, &blk }
  end

  class Connection
    def initialize(options = {})
    end
  end

end

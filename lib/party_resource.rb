module PartyResource

  def connect(name, options={})
    connection = Connection.new(options)
    meta_def(name) do |*args|
      connection.call(self, *args)
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

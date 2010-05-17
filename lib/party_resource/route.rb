module PartyResource
  class Route

    def initialize(options = {})
      options[:verb] = :get
      options[:path] = options.delete(options[:verb])
      @options = options
    end

    def call(context, *args)
      path = Path.new(@options[:path], context)
      :foo
    end
  end
end


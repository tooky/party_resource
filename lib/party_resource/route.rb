module PartyResource
  class Route

    VERBS = [:get, :post, :put, :delete]

    def initialize(options = {})
      @options = transform_options(options)
    end

    def call(context, *args)
      path = Path.new(@options[:path], context)
      :foo
    end

    private
    def transform_options(options)
      verbs = options.keys & VERBS
      raise ArgumentError.new("Must define only one verb (#{verbs.inspect} defined)") unless verbs.size == 1
      options[:verb] = verbs.first
      options[:path] = options.delete(options[:verb])
      options
    end
  end
end


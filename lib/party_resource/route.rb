module PartyResource
  class Route

    VERBS = [:get, :post, :put, :delete]

    def initialize(options = {})
      @options = transform_options(options)
    end

    def call(context, *args)
      raise ArgumentError, "wrong number of arguments (#{args.size} for #{@options[:with].size})" unless @options[:with].size == args.size
      args = Hash[*@options[:with].zip(args).flatten]
      path = Request.new(@options[:verb], @options[:path], context, args)
      raw_result = connector.fetch(path)
      @options[:as].new(raw_result)
    end

    def connector
      PartyResource::Connector(@options[:connector])
    end

    private
    def transform_options(options)
      options = {:with => []}.merge(options)
      transform_with_option(options)
      transform_location_options(options)
      options
    end

    def transform_with_option(options)
      options[:with] = [options[:with]] unless options[:with].is_a?(Array)
    end

    def transform_location_options(options)
      verbs = options.keys & VERBS
      raise ArgumentError.new("Must define only one verb (#{verbs.inspect} defined)") unless verbs.size == 1
      options[:verb] = verbs.first
      options[:path] = options.delete(options[:verb])
    end
  end
end


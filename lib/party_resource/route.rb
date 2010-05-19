module PartyResource
  class Route

    VERBS = [:get, :post, :put, :delete]

    def initialize(options = {})
      @options = transform_options(options)
    end

    def call(context, *args)
      raise ArgumentError, "wrong number of arguments (#{args.size} for #{@options[:with].size})" unless @options[:with].size == args.size
      build_result.call connector.fetch(request(context, args))
    end

    def connector
      PartyResource::Connector(@options[:connector])
    end

    private
    def request(context, args)
      Request.new(@options[:verb], @options[:path], context, args_hash(args))
    end

    def args_hash(args)
      Hash[*@options[:with].zip(args).flatten]
    end

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
      raise ArgumentError, "Must define only one verb (#{verbs.inspect} defined)" unless verbs.size == 1
      options[:verb] = verbs.first
      options[:path] = options.delete(options[:verb])
    end

    def build_result
      return lambda {|raw_result| raw_result} if wants_raw_result?
      return lambda {|raw_result| return_type.send(return_method,raw_result) } unless wants_object?
      builder
    end

    def wants_raw_result?
      return_type == :raw
    end

    def wants_object?
      builder.is_a?(Proc)
    end

    def return_type
      builder.is_a?(Array) ? builder.first : builder
    end

    def return_method
      builder.is_a?(Array) ? builder.last : :new
    end

    def builder
      @options[:as]
    end
  end
end


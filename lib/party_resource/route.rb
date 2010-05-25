require 'party_resource/buildable'
module PartyResource

  class Route
    include Buildable

    VERBS = [:get, :post, :put, :delete]

    def initialize(options = {})
      @options = transform_options(options)
    end

    def call(context, *args)
      options = args.pop if args.last.is_a?(Hash) && args.size == expected_args.size + 1
      raise ArgumentError, "wrong number of arguments (#{args.size} for #{expected_args.size})" unless expected_args.size == args.size
      begin
        builder.call(connector.fetch(request(context, args, options)), context, included(context))
      rescue Error => e
        name = e.class.name.split(/::/).last
        return @options[:rescue][name] if @options[:rescue].has_key?(name)
        raise
      end
    end

    def connector
      PartyResource::Connector(@options[:connector])
    end

    private
    def request(context, args, params)
      Request.new(@options[:verb], @options[:path], context, args_hash(args), params)
    end

    def args_hash(args)
      Hash[*expected_args.zip(args).flatten]
    end

    def transform_options(options)
      options = {:with => [], :including => {}, :rescue => {}}.merge(options)
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

    def expected_args
      @options[:with]
    end

    def including
      @options[:including]
    end

    def included(context)
      return {} if including.empty?

      context_hash = context.parameter_values(including.values)

      including.inject({}) do |hash, pair|
        hash[pair.first] = context_hash[pair.last]
        hash
      end
    end

  end
end


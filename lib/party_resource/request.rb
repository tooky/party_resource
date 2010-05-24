module PartyResource
  class Request
    attr_reader :verb
    def initialize(verb, path, context, args, params)
      @verb = verb
      @path = path
      @args = args
      @context = context
      @params = params || {}
    end

    def path
      args = @context.parameter_values(path_params - @args.keys).merge(@args)
      URI.encode(path_params.inject(@path) do |path, param|
        path.gsub(":#{param}", args[param].to_s)
      end)
    end

    def data
      @params.merge(@args).reject{|name,value| path_params.include?(name)}
    end

    def http_data(options={})
      options = options.merge(self.params_key => self.data) unless self.data.empty?
      options
    end

    def params_key
      verb == :get ? :query : :body
    end

    def path_params
      @path.scan(/:([\w]+)/).flatten.map{|p| p.to_sym}
    end
  end
end

module PartyResource
  class Request
    attr_reader :verb
    def initialize(verb, path, context, args)
      @verb = verb
      @path = path
      @args = args
      @context = context
    end

    def path
      args = @context.parameter_values(path_params - @args.keys).merge(@args)
      path_params.inject(@path) do |path, param|
        path.gsub(":#{param}", args[param].to_s)
      end
    end

    def data
      @args.reject{|name,value| path_params.include?(name)}
    end

    def path_params
      @path.scan(/:([\w]+)/).flatten.map{|p| p.to_sym}
    end
  end
end

module PartyResource
  class Request
    attr_reader :verb, :path
    def initialize(verb, path, context, args)
      @verb = verb
      @path = path
      @args = args
    end

    def data
      @args
    end
  end
end

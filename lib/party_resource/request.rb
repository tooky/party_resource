module PartyResource
  class Request
    attr_reader :verb, :path
    def initialize(verb, path, context, args)
      @verb = verb
      @path = path
    end

    def data
      {}
    end
  end
end

module PartyResource

  Error = Class.new(StandardError)

  class MissingParameter < Error
    def initialize(parameter, context)
      @parameter = parameter
      @context = context
    end

    def to_s
      "No value for #{@parameter} is available in #{@context}"
    end
  end

  class NoConnector < Error
    def initialize(name)
      @name = name
    end

    def to_s
      "Connector '#{@name}' has not been defined"
    end
  end

end

require 'party_resource/buildable'
module PartyResource
  class Property
    include Buildable

    attr :name

    def initialize(name, options)
      @name = name
      @options = {:as => :raw}.merge(options || {})
    end

    def from
      [@options[:from] || name].flatten
    end

    def value_from(hash)
      builder.call retrieve_value(hash)
    end

    def retrieve_value(hash)
      from.inject(hash) do |value, name|
        value[name] unless value.nil?
      end || hash[name]
    end
  end
end

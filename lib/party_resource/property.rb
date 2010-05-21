require 'party_resource/buildable'
module PartyResource
  class Property
    include Buildable

    attr :name

    def initialize(name, options)
      @name = name
      @options = {:as => :raw}.merge(options || {})
    end

    def value_from(hash)
      builder.call retrieve_value(hash)
    end

    def has_value_in?(hash)
      input_hash(hash).has_key?(input_key) || hash.has_key?(name)
    end

    private
    def retrieve_value(hash)
      input_hash(hash)[input_key] || hash[name]
    end

    def input_hash(hash)
      input_keys[0..-2].inject(hash) do |value, name|
        value[name] || {}
      end
    end

    def input_keys
      [@options[:from] || name].flatten
    end

    def input_key
      input_keys.last
    end
  end
end

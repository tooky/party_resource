require 'party_resource/buildable'
module PartyResource
  class Property
    include Buildable

    attr :name

    def initialize(name, options)
      @name = name
      @options = {:as => :raw}.merge(options || {})
    end

    def value_from(hash, context)
      builder.call retrieve_value(hash), context
    end

    def has_value_in?(hash)
      input_hash(hash).has_key?(input_key) || hash.has_key?(name)
    end

    def to_hash(context)
      value = context.send(name)
      return {} if value.nil?
      value = value.to_properties_hash if value.respond_to?(:to_properties_hash)
      output_keys.reverse.inject(value) do |value, key|
        {key => value}
      end
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

    def output_keys
      [@options[:to] || input_keys].flatten
    end

    def input_key
      input_keys.last
    end
  end
end

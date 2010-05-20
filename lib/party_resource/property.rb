class Property

  attr :name

  def initialize(name, options)
    @name = name
    @options = options || {}
  end

  def from
    [@options[:from] || name].flatten
  end

  def value_from(hash)
    from.inject(hash) do |value, name|
      value[name] unless value.nil?
    end
  end
end

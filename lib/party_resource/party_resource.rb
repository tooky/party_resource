require 'active_support/core_ext/hash/indifferent_access'
Hash.send(:include, ActiveSupport::CoreExtensions::Hash::IndifferentAccess) unless Hash.method_defined?(:with_indifferent_access)

module PartyResource

  module ClassMethods
    include MethodDefine

    # Connect a method call to a restful uri
    # @return [nil]
    def connect(name, options={})
      level = options.delete(:on)
      options = {:as => :self, :connector => @party_connector}.merge(options)
      route = Route.new(options)

      define_method_on(level, name) do |*args|
        route.call(self, *args)
      end
      nil
    end

    # Define a property
    # @overload property(*names, options={})
    #   @param [Symbol] names list of property names
    #   @param [Hash] options the options to use to create the property
    #   @option options :as (:self) How to build property
    #
    #     :raw - raw data
    #
    #     :self - self.new(data)
    #
    #     class - class.new(data)
    #
    #     Array(class, :method) - class.method(data)
    #
    #     lambda - lambda.call(data)
    #   @option options :from (property name) where to find property value in incomming data hash
    #
    #     symbol - name
    #
    #     array - list of nested hash keys
    #   @option options :to (from value) where to put property value in outgoing incomming data hash
    #
    #     symbol - name
    #
    #     array - list of nested hash keys
    #   @return [nil]
    def property(*names)
      options = names.pop if names.last.is_a?(Hash)
      names.each do |name|
        name = name.to_sym
        define_method name do
          get_property(name)
        end
        @property_list ||= []
        @property_list << Property.new(name, options)
      end
      nil
    end

    # Set the name of the connector to use for this class
    # @return [nil]
    def party_connector(name)
      @party_connector = name
      nil
    end

    private
    def property_list
      @property_list ||= []
      if superclass.include?(PartyResource)
        @property_list + superclass.send(:property_list)
      else
        @property_list
      end
    end
  end

  module ParameterValues
    def parameter_values(list)
      list.inject({}) do |out, var|
        begin
          out[var] = send(var)
        rescue
          raise Exceptions::MissingParameter.new(var, self)
        end
        out
      end
    end
  end

  # Converts the objects properties to a hash
  # @return [Hash] a hash of all the properties
  def to_properties_hash
    self.class.send(:property_list).inject({}) do |hash, property|
      hash.merge(property.to_hash(self))
    end
  end

  # Test if all properties are equal
  def properties_equal?(other)
    begin
      self.class.send(:property_list).all? {|property| self.send(property.name) == other.send(property.name) }
    rescue NoMethodError
      false
    end
  end


  private
  def populate_properties(hash)
    hash = hash.with_indifferent_access
    self.class.send(:property_list).each do |property|
      instance_variable_set("@#{property.name}", property.value_from(hash, self)) if property.has_value_in?(hash)
    end
  end

  def self.included(klass)
    klass.extend(ClassMethods)
    klass.extend(ParameterValues)
    klass.send(:include, ParameterValues)
  end

  def get_property(name)
    instance_variable_get("@#{name}")
  end
end

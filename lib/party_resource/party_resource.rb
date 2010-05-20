require 'active_support/core_ext/hash/indifferent_access'
Hash.send(:include, ActiveSupport::CoreExtensions::Hash::IndifferentAccess) unless Hash.method_defined?(:with_indifferent_access)

module PartyResource

  module ClassMethods
    include MethodDefine

    def connect(name, options={})
      level = options.delete(:on)
      options = {:as => self}.merge(options)
      route = Route.new(options)

      define_method_on(level, name) do |*args|
        route.call(self, *args)
      end
    end

    def property(*names)
      options = names.pop if names.last.is_a?(Hash)
      names.each do |name|
        name = name.to_sym
        attr_reader name
        property_list[name] = options || {}
      end
    end

    private
    def property_list
      @property_list ||= {}
    end
  end

  module ParameterValues
    def parameter_values(list)
      list.inject({}) do |out, var|
        begin
          out[var] = send(var)
        rescue
          raise MissingParameter.new(var, self)
        end
        out
      end
    end
  end

  private
  def populate_properties(hash)
    hash = hash.with_indifferent_access
    self.class.send(:property_list).each do |name, options|
      instance_variable_set("@#{name}", hash[options[:from] || name])
    end
  end

  def self.included(klass)
    klass.extend(ClassMethods)
    klass.extend(ParameterValues)
    klass.send(:include, ParameterValues)
  end
end

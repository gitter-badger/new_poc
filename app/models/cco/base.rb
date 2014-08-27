
module CCO
  # NEW base cross-level conversion object, converting from entity to
  # implementation-model instance and back.
  class Base
    def self.attr_names
      fail NoMethodError, 'Must be overridden in subclass'
    end

    def self.entity
      fail NoMethodError, 'Must be overridden in subclass'
    end

    def self.model
      fail NoMethodError, 'Must be overridden in subclass'
    end

    def self.model_instance_based_on(_entity)
      model.new
    end

    def self.from_entity(entity, _params = {})
      impl = model_instance_based_on entity
      attr_names.each do |attr|
        assign_sym = "#{attr}=".to_sym
        impl.send assign_sym, entity.send(attr)
      end
      impl
    end

    def self.entity_instance_based_on(attrs)
      entity.new attrs
    end

    def self.to_entity(impl, _params = {})
      attrs = {}
      attr_names.each { |attr| attrs[attr] = impl.send attr }
      entity_instance_based_on attrs
    end
  end # class CCO::Base
end # module CCO

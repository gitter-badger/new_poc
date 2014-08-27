
require_relative 'base'

module CCO
  # CCO for Users.
  class UserCCO < Base
    def self.attr_names
      [:name, :email, :profile, :slug]
    end

    def self.entity
      User
    end

    def self.model
      UserData
    end

    def self.entity_instance_based_on(attrs)
      entity.new attrs
    end

    def self.model_instance_based_on(entity)
      model.find_or_initialize_by slug: entity.slug
    end

    def self.to_entity(impl, params = {})
      current_session = params.fetch :current_session, nil
      ret = super
      ret.session_token = current_session if _validate_session(current_session)
      ret
    end

    def self._validate_session(current_session)
      # FIXME: Need to actually validate incoming parameter!
      current_session
    end
  end # class CCO::UserCCO
end # module CCO

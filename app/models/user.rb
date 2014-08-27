
# Everything other entities or DSOs need to know about a user should be in here.
class User
  attr_reader :name, :email, :profile, :slug
  attr_writer :session_token

  def initialize(attrs = {})
    ivars = [:name, :email, :profile, :session_token, :slug]
    attrs.each do |k, v|
      ivar_sym = ['@', k].join.to_sym
      instance_variable_set ivar_sym, v if ivars.include? k
    end
  end

  def authenticated?
    @session_token.present?
  end

  def registered?
    return false unless name.present?
    @registered ||= (name != self.class.guest_user_name)
  end

  def self.guest_user_name
    'Guest User'
  end
end # class User

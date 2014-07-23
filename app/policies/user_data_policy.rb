
# Pundit authorisation policy for UserData record instances.
class UserDataPolicy < ApplicationPolicy
  def create?
    # Should be based on `user.registered?` -- but that's an *entity* concept.
    user.name == user.class.first.name  # accept the Guest User only
  end
end # class UserDataPolicy
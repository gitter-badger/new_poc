
# Pundit authorisation policy for PostData record instances.
class PostDataPolicy < ApplicationPolicy
  def create?
    # Should return `user.registered?` -- but that's an *entity* concept.
    user.name != user.class.first.name  # reject the Guest User
  end

  def edit?
    record.author_name == user.name
  end

  def update?
    edit?
  end
end # class PostDataPolicy

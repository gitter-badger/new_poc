
# Main application controller. Hang things off here that are needed by multiple
# controllers (which all subclass this one).
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :init_blog

  private

  def init_blog
    # A reminder: @blog_dto is the "implementation detail" Rails model
    # responsible for persistence and database-level validation. It's used as a
    # data source/sink by various DSOs, e.g., DSO::BlogListingBuilder, to build
    # their own internal representations/views of. Thus you can have DSOs like
    # DSO::BlogListingBuilder that try very hard to lock out any modification of
    # the underlying data, without interfering in the abillity of *other* DSOs
    # to, say, add Posts to a Blog.
    @blog_dto = THE_BLOG
  end
end

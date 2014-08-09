
require 'blog_selector'   # only needed for #new_post_params
require 'permissive_post_creator'
require 'post_creator_and_publisher'

# PostsController: actions related to Posts within our "fancy" blog.
class PostsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :article_not_found

  def new
    post = DSO::PermissivePostCreator.run!
    # The DSO hands back an entity; Rails needs to see an implementation model
    @post = CCO::PostCCO.from_entity post
    authorize @post
    @post
  end

  def create
    post = DSO::PostCreatorAndPublisher.run! params: tweak_create_params(params)
    @post = CCO::PostCCO.from_entity post
    @post.valid?
    authorize @post
    process_create_result
  end

  def show
    post = PostData.find params[:id]
    @post = PostDataDecorator.new(post)
    authorize @post
  end

  private

  def article_not_found
    redirect_to root_url, not_found_redirect_params
  end

  def not_found_redirect_params
    slug = params[:id]
    { flash: { alert: %(There is no article with an ID of "#{slug}"!) } }
  end

  def process_create_result
    # NOTE: It Would Be Very Nice If this used MQs or etc. to be more direct.
    if @post.valid?
      @post.save!
      redirect_to(root_path, redirect_params)
    else
      render 'new'
    end
  end

  def redirect_params
    { flash: { success:  'Post added!' } }
  end

  def tweak_create_params(params)
    user = CCO::UserCCO.to_entity(current_user)
    params[:post_data][:author_name] = user.name if user.registered?
    params
  end
end # class Blog::PostsController

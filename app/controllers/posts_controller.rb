
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

  def edit
    @post = PostData.find params[:id]
    authorize @post
  end

  def show
    post = PostData.find params[:id]
    @post = PostDataDecorator.new(post)
    authorize @post
  end

  # def update
  #   @post = PostData.find params[:id]
  #   authorize @post
  #   entity = CCO::PostCCO.to_entity @post
  #   result = DSO::PostUpdater.run user: current_user,
  #                                 post: @post,
  #                                 post_data: params[:post_data]
  #   if result.valid?
  #     update_and_redirect_with result.result
  #   else
  #     render 'edit'
  #   end
  # end

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

  # def update_and_redirect_with(attribs)
  #   @post.update_attributes attribs
  #   message = "You successfully updated your post, '#{@post.title}'"
  #   redirect_to post_path(@post.slug), flash: { success: message }
  # end
end # class Blog::PostsController

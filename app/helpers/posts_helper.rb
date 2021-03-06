
# Old-style junk drawer of view-helper functions, etc.
module PostsHelper
  def new_post_form_attributes(_params = {})
    attribs = shared_post_form_attributes 'new_post'
    attribs[:url] = posts_path
    attribs
  end

  def edit_post_form_attributes(post)
    attribs = shared_post_form_attributes 'edit_post'
    attribs[:url] = post_path(post)
    attribs
  end

  def status_select_options(post)
    option_items = [%w(draft draft), %w(public public)]
    # `status` appears to be an existing ActiveRecord::Base field. :(
    current_status = post.post_status || 'draft'
    options_for_select option_items, current_status
  end

  def summarise_posts(count = 10)
    allowed_posts = PostDataDecorator.decorate_collection data_policy_scope
    the_sorter = sorter_hack
    PostsSummariser.new do |s|
      s.count = count
      sorter -> (data) { the_sorter.call data }
    end.summarise(allowed_posts)
  end

  private

  def data_policy_scope
    Pundit.policy_scope! pundit_user, PostData.all
  end

  def shared_post_form_attributes(which)
    {
      html: {
        class:  ['form-horizontal', which].join(' '),
        id:     which
      },
      role:     'form'
    }
  end

  def sorter_hack
    lambda do |data|
      drafts = data.reject(&:published?).sort_by(&:updated_at)
      posts = data.select(&:published?).sort_by(&:pubdate)
      [posts, drafts].flatten
    end
  end
end

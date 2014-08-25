
# Old-style junk drawer of view-helper functions, etc.
module PostsHelper
  def new_post_form_attributes
    shared_post_form_attributes 'new_post'
  end

  def edit_post_form_attributes
    shared_post_form_attributes 'edit_post'
  end

  private

  def shared_post_form_attributes(which)
    {
      html: {
        class:  ['form-horizontal', which].join(' '),
        id:     which
      },
      role:     'form',
      url:      posts_path
    }
  end
end

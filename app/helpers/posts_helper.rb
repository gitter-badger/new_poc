
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

  private

  def shared_post_form_attributes(which)
    {
      html: {
        class:  ['form-horizontal', which].join(' '),
        id:     which
      },
      role:     'form'
    }
  end
end


module DSO
  # "Placeholder" blog posts, for before we're able to create our own posts.
  class PlaceholderBuilder < ActiveInteraction::Base
    interface :blog, methods: [:new_post]

    def execute
      publish_post 'Paint just applied',
                   "Paint just applied. It's a lovely orangey-purple!"
      publish_post 'Still wet', 'Paint is still quite wet. No bubbling yet!'
      true  # we succeeded, didn't we?
    end

    def publish_post(title, body)
      post = blog.new_post
      post.title = title
      post.body = body
      post.publish
    end
  end # class DSO::PlaceholderBuilder
end # module DSO


require 'blog_listing_builder'

module DSO
  # "Placeholder" blog posts, for before we're able to create our own posts.
  class PlaceholderBuilder < ActiveInteraction::Base
    interface :blog, methods: [:title, :subtitle, :entries]

    def execute
      @new_blog = new_blog_from blog
      publish_post 'Paint just applied',
                   "Paint just applied. It's a lovely orangey-purple!"
      publish_post 'Still wet', 'Paint is still quite wet. No bubbling yet!'
      # return read-only data
      BlogListingBuilder.run! blog: @new_blog
    end

    def new_blog_from(blog)
      ret = Blog.new
      ret.instance_variable_set :@title, blog.instance_variable_get(:@title)
      ret.instance_variable_set :@subtitle,
                                blog.instance_variable_get(:@subtitle)
      ret
    end

    def publish_post(title, body)
      post = @new_blog.new_post
      post.title = title
      post.body = body
      post.publish
    end
  end # class DSO::PlaceholderBuilder
end # module DSO

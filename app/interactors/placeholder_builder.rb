
require 'blog_listing_builder'

module DSO
  # "Placeholder" blog posts, for before we're able to create our own posts.
  class PlaceholderBuilder < ActiveInteraction::Base
    interface :blog, methods: [:title, :subtitle, :entries]

    def execute
      dto = BlogDTOUpdater.new(blog) do |updater|
        updater.publish_post 'Paint just applied',
                             "Paint just applied. It's a lovely orangey-purple!"
        updater.publish_post 'Still wet',
                             'Paint is still quite wet. No bubbling yet!'
      end
      BlogListingBuilder.run! blog: dto.to_blog
    end

    # Wraps adding posts to a Blog DTO with specified title and subtitle.
    class BlogDTOUpdater
      # You'd think there'd be a standard method to do this, and you'd be almost
      # right. Both the Ruby `Object#clone` method and the Rails API method
      # `ActiveRecord#clone` (see documentation at
      # http://ruby-doc.org/core-2.1.0/Object.html#method-i-clone and
      # http://apidock.com/rails/ActiveRecord/Core/dup respectively) do what are
      # called *shallow* copies, which causes problems for things like Rails
      # attributes and relations. The Rails doc is actually quite good about
      # things like where it says "The extent of a "deep" copy is application
      # specific and is therefore left to the application to implement according
      # to its need." IOW, you're on your own. Hence, this.
      def initialize(blog_data, &block)
        @wrapped = Blog.new
        @wrapped.instance_variable_set :@title, blog_data.title
        @wrapped.instance_variable_set :@subtitle, blog_data.subtitle
        block.yield(self) if block_given?
      end

      def publish_post(title, body)
        post = @wrapped.new_post
        post.title = title
        post.body = body
        post.publish
      end

      # This little dance (the protected attr_reader used here) is to elminiate
      # a RuboCop warning "Use attr_reader to define trivial reader methods"
      # when #to_blog merely returns @wrapped. Pffft.
      def to_blog
        wrapped
      end

      protected

      attr_reader :wrapped
    end
  end # class DSO::PlaceholderBuilder
end # module DSO

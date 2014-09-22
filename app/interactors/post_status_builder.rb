
require 'decorator_shared/timestamp_builder'

module DSO
  # If the specified public Post exists and the specified User is authorised to
  # read it, then this returns a PostStatus instance. If the specified User is
  # the Post author, then will return a PostStatus instance whether the Post is
  # public or a draft.
  class PostStatusBuilder < ActiveInteraction::Base
    # Error when slug is not found
    class InvalidPostSlug
      def initialize(slug)
        message_str = "Invalid message slug specified: '#{slug}'."
        fail message_str
      end
    end

    model :user, class: parent.parent::User
    model :blog, class: parent.parent::Blog
    # Default will never match a properly-formed slug.
    string :post_slug, default: 'NO SLUG SPECIFIED -- TRY AGAIN!'

    def execute
      FancyOpenStruct.new status: post_status, pubdate_str: pubdate_str
    end

    private

    def post
      ret = blog.find do |post|
        return nil unless post.slug == post_slug
        if post.published?
          post
        else
          post.author_name == user.name
        end
      end
      return ret if ret
      InvalidPostSlug.new post_slug
    end

    def post_status
      if post.pubdate
        :public
      else
        :draft
      end
    end

    def pubdate_str
      if post.pubdate
        extend DecoratorShared
        timestamp_for post.pubdate
      else
        'DRAFT &hellip; Unpublished'
      end
    end
  end # class DSO::PostStatusBuilder
end # module DSO

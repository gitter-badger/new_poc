
module DSO
  # A Post must have methods #valid? and #publish. If the instance passed in
  # returns a truthy value from #valid?, its #publish method is called and
  # its return value is returned as the DSO outcome. Simple enough for you?
  class BlogPostAdder < ActiveInteraction::Base
    validate :validate_post
    model :post, class: parent.parent::Post

    def execute
      post.public_send post_method_message
    end

    private

    def post_method_message
      return :publish if should_publish?
      :add_to_blog
    end

    def should_publish?
      post.pubdate.present?
    end

    def validate_post
      return true if post.valid?
      post.error_messages.each { |message| errors.add :post, message }
    end
  end
end # module DSO

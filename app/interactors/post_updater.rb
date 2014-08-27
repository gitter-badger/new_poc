
module DSO
  # Verifies that requested Post value object is valid
  class PostUpdater < ActiveInteraction::Base
    model :user
    model :post
    hash :post_data, default: {} do
      string :slug, default: '', strip: true
      string :title, default: '', strip: true
      string :image_url, default: '', strip: true
      string :body, default: '', strip: true
    end

    def execute
      ret = nil
      if post.author_name == user.name
        data = Marshal.load(Marshal.dump post_data)
        data[:blog] = post.blog
        ret = Post.new data
      end
      ret
    end
  end # class DSO::PostUpdater
end # module DSO

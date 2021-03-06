
module DSO
  # Build list of information about a blog for presentation: title, subtitle,
  # entry data.
  class BlogSelector < ActiveInteraction::Base
    hash :params, default: {} do
      hash :blog_params, default: {} do
        integer :id, default: 1
      end
    end

    def execute
      Blog.new # id: params[:blog_params][:id]
    end
  end # class DSO::BlogSelector
end # module DSO

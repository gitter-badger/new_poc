
require_relative 'base'
require 'blo/blog_data_boundary'

module CCO
  # Third-generation CCO for Blogs.
  class BlogCCO < Base
    def self.attr_names
      [:title, :subtitle]
    end

    def self.entity
      Blog
    end

    def self.model
      BlogData
    end

    def self.entity_instance_based_on(_attrs)
      entity.new
    end

    def self.model_instance_based_on(entity)
      # We only support a single blog at present, so this is easy
      ret = model.first
      ret.title = entity.title
      ret.subtitle = entity.subtitle
      ret
    end

    def self.from_entity(entity, params = {})
      default_callback = ->(_post) {}
      post_callback = params.fetch :post_callback, default_callback
      ret = super
      entity.entries.each do |post|
        post_callback.call PostCCO.from_entity(post)
      end
      ret
    end

    def self.to_entity(impl, _params = {})
      ret = super
      ::BLO::BlogDataBoundary.new(impl).entries.each do |entry|
        ret.entries << entry
      end
      ret
    end
  end # class CCO::BlogCCO
end # module CCO

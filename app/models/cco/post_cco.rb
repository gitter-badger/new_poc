
module CCO
  # Cross-layer conversion object for Posts. API (slightly) tailored from Base.
  # NOTE: To add a converted entity to a Blog instance, use #add_entry, *NOT*
  #       #new_post. The entity comes back thinking it's not attached to *any*
  #       Blog instance, which is almost certainly not what you want.
  #       You Have Been Warned.
  class PostCCO < Base
    def self.attr_names
      [:title, :body, :image_url, :pubdate, :author_name, :slug]
    end

    def self.entity
      Post
    end

    def self.model
      PostData
    end

    def self.model_instance_based_on(entity)
      attrs = { slug: entity.slug, author_name: entity.author_name }
      model.find_or_initialize_by attrs
    end

    def self.entity_instance_based_on(attrs_in)
      attrs = {}
      attr_names.each { |attr| attrs[attr] = attrs_in[attr] }
      entity.new attrs
    end
  end # class CCO::PostCCO
end # module CCO

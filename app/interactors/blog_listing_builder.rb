
require_relative 'responder_setup'

module DSO
  # Build list of information about a blog for presentation: title, subtitle,
  # entry data.
  class BlogListingBuilder < ActiveInteraction::Base
    include Wisper::Publisher
    extend ResponderSetup
    interface :blog, methods: [:title, :subtitle, :entries]

    # Eventually, this is where we'd sort and filter posts being presented to
    # the user (public/private/draft posts; ordering, limiting, etc.) We "fake
    # it" by returning an object with *a read-only copy of* the details.
    def execute
      Builder.new blog
    end

    # Why? So we can use attr_reader to lock down write access to (most)
    # attributes, which OpenStruct/FancyOpenStruct don't support
    # (intentionally). This *is not* a boundary-level object (BLO) in our
    # cleaner architecture, since it knows nothing about a Blog's internals.
    # It makes a *copy of* data from the Blog using exclusively the three
    # public methods declared in the containing ActiveInteraction. It *does*,
    # however, know that an entry, or post, has a title and a body.
    class Builder
      attr_reader :title, :subtitle, :entries

      def initialize(blog)
        @title = blog.title
        @subtitle = blog.subtitle
        @entries = copy_entries_from blog
      end

      private

      # Information about a blog entry, currently only body and title. This is
      # a *subset* of what's stored in the database (e.g., no timestamps), and
      # is meant to quack properly to code that wants to *think* of a thing as a
      # blog post, but has no business whatever touching the actual machinery.
      # This is arguably a permissible violation of the Law of Leaky
      # Abstractions, invoking the Interface Segregation Principle.
      class Entry
        attr_reader :title, :body
        def initialize(post)
          @title = post.title
          @body = post.body
        end
      end # class DSO::BlogListingBuilder::Builder::Entry

      def copy_entries_from(blog)
        ret = []
        blog.entries.each { |post| ret << Entry.new(post).freeze }
        ret.freeze
      end
    end # class DSO::BlogListingBuilder::Builder2
  end # class DSO::BlogListingBuilder
end # module DSO

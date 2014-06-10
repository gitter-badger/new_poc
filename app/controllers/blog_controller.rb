
require 'blog_listing_builder'
require 'placeholder_builder'

# A controller should assign resources and redirect flow. Full stop.
class BlogController < ApplicationController
  def index
    blog = DSO::BlogListingBuilder.run! blog: @blog_dto
    @blog = DSO::PlaceholderBuilder.run! blog: blog
  end
end

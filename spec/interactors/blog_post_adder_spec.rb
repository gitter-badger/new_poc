
require 'spec_helper'

require 'blog_post_adder'

# Module DSO contains our Domain Service Objects, aka "interactors".
module DSO
  describe BlogPostAdder do

    let(:blog) { Blog.new }
    let(:new_draft_post) do
      attribs = FactoryGirl.attributes_for :post_datum, :new_post, :draft_post
      blog.new_post attribs
    end
    let(:new_public_post) do
      attribs = FactoryGirl.attributes_for :post_datum, :new_post, :public_post
      blog.new_post attribs
    end
    let(:saved_draft_post) do
      attribs = FactoryGirl.attributes_for :post_datum, :saved_post, :draft_post
      blog.new_post attribs
    end
    let(:saved_public_post) do
      attribs = FactoryGirl.attributes_for :post_datum,
                                           :saved_post,
                                           :public_post
      blog.new_post attribs
    end
    let(:draft_posts) { [new_draft_post, saved_draft_post] }
    let(:public_posts) { [new_public_post, saved_public_post] }
    let(:all_posts) { draft_posts + public_posts }
    let(:klass) { BlogPostAdder }

    it 'does not raise an error when called with a valid post' do
      all_posts.each do |post|
        expect { klass.run! post: post }.not_to raise_error
      end
    end

    it 'publishes public posts to the Blog' do
      public_posts.each { |post| klass.run! post: post }
      blog.each { |post| expect(post.pubdate).to be_a Time }
    end

    it 'adds draft posts to the Blog without publishing them' do
      draft_posts.each { |post| klass.run! post: post }
      blog.each { |post| expect(post.pubdate).to be nil }
    end

    describe 'reports failure when called with' do

      context 'an invalid Post, by' do
        let(:post) { saved_public_post.tap { |post| post.title = nil } }

        it 'returning false from the #valid? method' do
          expect(klass.run post: post).to_not be_valid
        end

        it 'reporting the correct full error message' do
          # message = "Post Title can't be blank" # See Issue #94.
          message = /\APost Title .+?\z/
          result = klass.run post: post
          expect(result.errors.full_messages).to have(1).item
          expect(result.errors.full_messages.first).to match message
        end
      end # context 'an invalid Post, by'
    end # describe 'fails when called with'
  end # describe DSO::BlogPostAdder
end # module DSO

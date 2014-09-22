
require 'spec_helper'

require 'post_status_builder'

# Module DSO contains our Domain Service Objects, aka "interactors".
module DSO
  describe PostStatusBuilder do
    let(:author) { User.new(FactoryGirl.attributes_for :user_datum) }
    let(:blog) { Blog.new }
    let(:draft_pubstr) { 'DRAFT &hellip; Unpublished' }
    let(:post_attribs) do
      FactoryGirl.attributes_for(:post_datum).tap do |attribs|
        attribs[:author_name] = author.name
        attribs[:slug] = attribs[:title].parameterize
      end
    end
    let(:draft_post) do
      blog.new_post(post_attribs).tap { |post| blog.add_entry post }
    end
    let(:public_post) do
      blog.new_post(post_attribs).tap(&:publish)
    end
    let(:klass) { PostStatusBuilder }

    context 'when called specifying the author of' do
      context 'a draft post' do
        let(:post) { draft_post }
        let(:instance) do
          klass.run! user: author, blog: blog, post_slug: post.slug
        end

        describe 'returns an object with' do
          it 'a draft marker from its #pubdate_str method' do
            expect(instance.pubdate_str).to eq draft_pubstr
          end

          it 'a :draft symbol from its #status method' do
            expect(instance.status).to be :draft
          end
        end # describe 'returns an object with'
      end # context 'a draft post'

      context 'a public post' do
        let(:post) { public_post }
        let(:instance) do
          klass.run! user: author, blog: blog, post_slug: post.slug
        end

        describe 'returns an object with' do
          it "the post's formatted pubdate from its #pubdate_str method" do
            expected = post.pubdate.strftime '%a %b %e %Y at %R %Z (%z)'
            expect(instance.pubdate_str).to eq expected
          end

          it 'a :public symbol from its #status method' do
            expect(instance.status).to be :public
          end
        end # describe 'returns an object with'
      end # context 'a public post'
    end # context 'when called specifying the author of'

    context 'when called specifying a User not the author and' do
      let(:user) { User.new(FactoryGirl.attributes_for :user_datum) }

      context 'a draft post' do
        let(:post) { draft_post }
        let(:instance) do
          klass.run! user: user, blog: blog, post_slug: post.slug
        end

        it 'raises an error' do
          message = "Invalid message slug specified: '#{post.slug}'."
          expect { instance }.to raise_error message
        end
      end # context 'a draft post'

      context 'a public post' do
        let(:post) { public_post }
        let(:instance) do
          klass.run! user: user, blog: blog, post_slug: post.slug
        end

        describe 'returns an object with' do
          it "the post's formatted pubdate from its #pubdate_str method" do
            expected = post.pubdate.strftime '%a %b %e %Y at %R %Z (%z)'
            expect(instance.pubdate_str).to eq expected
          end

          it 'a :public symbol from its #status method' do
            expect(instance.status).to be :public
          end
        end # describe 'returns an object with'
      end # context 'a public post'
    end # context 'when called specifying a User not the author and'
  end # describe DSO::PostStatusBuilder
end # module DSO


require 'spec_helper'

require 'cco/blog_cco'

# Second-generation CCO for Blogs. Does not (presently) subclass Base.
module CCO
  describe BlogCCO do
    let(:from) { BlogCCO.public_method :from_entity }
    let(:to) { BlogCCO.public_method :to_entity }
    let(:impl) { BlogData.first }
    let(:entity) { Blog.new }

    describe 'has a .from_entity method that' do

      it 'is a class method' do
        expect(from.receiver).to be BlogCCO
      end

      it 'takes a maximum of two parameters' do
        expect(from.arity.abs).to eq 2
      end

      describe 'takes two parameters, where' do
        it 'the first parameter is required' do
          param = from.parameters.first
          expect(param[0]).to be :req
        end

        it 'the second parameter is optional' do
          param = from.parameters.second
          expect(param[0]).to be :opt
        end
      end # describe 'takes two parameters, where'

      it 'accepts a BlogData instance as its first parameter' do
        expect { from.call entity }.to_not raise_error
      end

      context 'can be called with a Blog entity and no second param, ' do

        it 'returning a BlogData model instance' do
          expect(from.call entity).to be_a BlogData
        end

        describe 'returning a BlogData model instance that contains' do

          it "the entity's title attribute" do
            expect(from.call(entity).title).to eq entity.title
          end

          it "the entity's subtitle attribute" do
            expect(from.call(entity).subtitle).to eq entity.subtitle
          end
        end # describe 'returning a BlogData model instance that contains'
      end # context 'can be called with a BlogData... and no second param,'

      context 'can be called with both an entity and a lambda for posts' do

        let(:post_count) { 5 }
        let(:entity) do
          e = Blog.new
          # Why #create_list rather than #attributes_for_list as before? Slugs.
          FactoryGirl.create_list(:post_datum, post_count).each do |p|
            e.add_entry p
          end
          e
        end

        # Note that we can't add the PostData instances directly into the
        # BlogData instance. For one thing, there's currently no schema
        # provision for that; our single-Blog implementation naively uses all
        # PostData instances.
        it 'with the lambda called once with each Post entity' do
          the_posts = []
          callback = -> (post) { the_posts << post }
          from.call entity, post_callback: callback
          expect(the_posts).to have(post_count).entries
          the_posts.each { |post| expect(post).to be_a PostData }
        end
      end # context 'can be called with both an entity and a lambda for posts'
    end # describe 'has a .from_entity method that'

    describe 'has a .to_entity method that' do
      let(:impl) { BlogData.first }

      it 'is a class method' do
        expect(to.receiver).to be BlogCCO
      end

      it 'takes a maximum of two parameters' do
        expect(to.arity.abs).to be 2
      end

      it 'takes one required parameter' do
        expect(to.parameters.first[0]).to be :req
      end

      it 'takes a second optional parameter' do
        expect(to.parameters.last[0]).to be :opt
      end

      it 'returns a Blog instance when called with a BlogData parameter' do
        expect(BlogCCO.to_entity impl).to be_a Blog
      end

      describe 'returns a Blog instance with the correct' do
        let(:entity) { BlogCCO.to_entity impl }

        describe 'attribute values for' do
          it 'title' do
            expect(entity.title).to eq impl.title
          end

          it 'subtitle' do
            expect(entity.subtitle).to eq impl.subtitle
          end
        end # describe 'attribute values for'

        describe 'number of entries for' do

          it 'an empty blog' do
            expect(entity.entries).to be_empty
          end

          it 'a blog with entries' do
            FactoryGirl.create_list :post_datum, 3
            entity = BlogCCO.to_entity impl
            expect(entity).to have(3).entries
            PostData.delete_all
          end
        end # describe 'number of entries for'
      end # describe 'returns a Blog instance with the correct'
    end # describe 'has a .to_entity method that'
  end # describe CCO::BlogCCO
end # module CCO

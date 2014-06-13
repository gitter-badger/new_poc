
require 'spec_helper'

require 'blog_listing_builder'

# Module DSO contains our Domain Service Objects, aka "interactors".
module DSO
  describe BlogListingBuilder do

    def setup_blog
      ret = Blog.new
      post = ret.new_post
      post.title = 'First Title'
      post.body = 'First Body'
      post.publish
      post = ret.new_post
      post.title = 'Second Title'
      post.body = 'Second Body'
      post.publish
      ret
    end

    let(:klass) { BlogListingBuilder }
    let(:blog) { setup_blog }

    it 'can be called using a `blog` parameter' do
      expect { klass.setup_responders.run! blog: Blog.new }.to_not raise_error
    end

    it 'raises an error when no parameter is passed' do
      error = ActiveInteraction::InvalidInteractionError
      message = 'Blog is required'
      expect { klass.setup_responders.run! }.to raise_error error, message
    end

    describe 'copies values from the Blog instance for the' do

      subject(:obj) { klass.setup_responders.run! blog: blog }

      it 'title' do
        expect(obj.title).to eq blog.title
      end

      it 'subtitle' do
        expect(obj.subtitle).to eq blog.subtitle
      end

      it 'entries' do
        expect(obj.entries.length).to be blog.entries.length
        blog.entries.each_with_index do |entry, index|
          expect(entry.title).to eq obj.entries[index].title
          expect(entry.body).to eq obj.entries[index].body
        end
      end
    end # describe 'copies values from the Blog instance for the'

    it 'prohibits modification of attributes on returned object' do
      obj = klass.setup_responders.run! blog: setup_blog
      expect { obj.title = 'anything' }.to \
          raise_error NoMethodError, /undefined method `title='.+/
      expect { obj.subtitle = 'anything' }.to \
          raise_error NoMethodError, /undefined method `subtitle='.+/
      expect { obj.entries = [] }.to \
          raise_error NoMethodError, /undefined method `entries='.+/
      expect { obj.entries.first.title = 'foo' }.to \
          raise_error NoMethodError, /undefined method `title='.+/
      expect { obj.entries.first.body = 'foo' }.to \
          raise_error NoMethodError, /undefined method `body='.+/
      item = obj.entries.first
      expect { item.title = 'foo' }.to \
          raise_error NoMethodError, /undefined method `title='.+/
      expect { item.body = 'foo' }.to \
          raise_error NoMethodError, /undefined method `body='.+/
      dummy_params = FancyOpenStruct.new title: 'foo', body: 'bar'
      new_entry = BlogListingBuilder::Builder::Entry.new dummy_params
      expect { obj.entries << new_entry }.to \
          raise_error RuntimeError, /can't modify frozen Array/
    end

    it 'sets up responders properly' do
      # Dummy listener class for spec.
      class ExampleListener
        attr_reader :obj
        def foo(obj)
          @obj = deep_magick obj
        end

        private

        def deep_magick(_obj)
          # ...
        end
      end

      klass.setup_responders [ExampleListener]
      expect(Wisper::GlobalListeners.listeners.first).to be_an ExampleListener
      allowed_classes = Wisper::GlobalListeners
          .registrations
          .first
          .allowed_classes
      expect(allowed_classes.first).to eq klass.name
    end
  end # describe BlogListingBuilder
end # module DSO

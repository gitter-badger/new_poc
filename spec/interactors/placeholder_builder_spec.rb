
require 'spec_helper'

require 'placeholder_builder'

# Module DSO contains our Domain Service Objects, aka "interactors".
module DSO
  describe PlaceholderBuilder do

    let(:klass) { PlaceholderBuilder }
    let(:blog) { Blog.new }

    # before :each do
    #   @blog = Blog.new
    # end

    describe 'can be executed by passing in the blog as a parameter' do

      it 'reporting a successful outcome' do
        expect(klass.run! blog: blog).to be true
      end
    end # describe 'can be executed by passing in the blog as a parameter'

    it 'adds two posts to the Blog' do
      expect(blog).to have(0).entries
      klass.run! blog: blog
      expect(blog).to have(2).entries
    end

    describe 'updates the state of the Blog instance, so that it' do

      before :each do
        klass.run! blog: blog
      end

      after :each do |example|
        ivar_sym = ['@', example.description].join.to_sym
        expect(post.instance_variable_get ivar_sym).to eq @expected
      end

      describe 'has a first post that has the expected' do
        let(:post) { blog.entries.first }

        it :title do
          @expected = 'Paint just applied'
        end

        it :body do
          @expected = "Paint just applied. It's a lovely orangey-purple!"
        end
      end # describe 'has a first post that has the expected'

      describe 'has a second post that has the expected' do
        let(:post) { blog.entries.second }

        it :title do
          @expected = 'Still wet'
        end

        it :body do
          @expected = 'Paint is still quite wet. No bubbling yet!'
        end
      end # describe 'has a second post that has the expected'
    end # describe 'updates the state of the Blog instance, so that it'
  end # PlaceholderBuilder
end # module DSO

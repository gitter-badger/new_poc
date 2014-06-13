
require 'spec_helper'

describe BlogController do
  describe :routing.to_s, type: :routing do
    it { expect(get '/blog').to route_to 'blog#index' }
    it { expect(get '/blog/blog/new').to_not be_routable }
    it { expect(post '/blog/blog').to_not be_routable }
    it { expect(get '/blog/blog/1').to_not be_routable }
    it { expect(get '/blog/blog/edit').to_not be_routable }
    it { expect(put '/blog/blog/1').to_not be_routable }
    it { expect(delete '/blog/blog/1').to_not be_routable }
  end

  describe :helpers.to_s do
    it { expect(blog_index_path).to eq('/blog') }
  end

  describe "GET 'index'" do
    it 'returns http success' do
      get :index
      response.should be_success
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template 'index'
    end

    describe 'assigns a "blog" controller variable that' do

      after :each do
        get :index
        blog = assigns 'blog'
        expect(blog.send @field).to eq @expected
      end

      it 'has the expected title' do
        @expected = 'Watching Paint Dry'
        @field = :title
      end

      it 'has the expected subtitle' do
        @expected = 'The trusted source for paint drying news and opinion'
        @field = :subtitle
      end

      # it 'has the expected entries' do
      #   @expected = []
      #   @field = :entries
      # end
    end # describe 'assigns a "blog" controller variable that'

    it 'loads placeholder posts into the blog :entries field' do
      get :index
      blog = assigns 'blog'
      expect(blog).to have(2).entries
    end
  end # describe "GET 'index'"
end


require 'spec_helper'

# Posts controller dispatches post-specific actions
describe PostsController do
  describe :routing.to_s, type: :routing do
    it { expect(get '/posts/new').to route_to 'posts#new' }
    it { expect(post '/posts').to route_to 'posts#create' }
    it { expect(get '/posts').to_not be_routable }
    it { expect(get '/posts/1').to_not be_routable }
    it { expect(get '/posts/edit').to_not be_routable }
    it { expect(put '/posts/1').to_not be_routable }
    it { expect(delete '/posts/1').to_not be_routable }
  end

  describe :helpers.to_s do
    it { expect(new_post_path).to eq('/posts/new') }
  end

  describe "GET 'new'" do
    it 'returns http success' do
      get :new
      response.should be_success
    end

    it 'assigns a Post to :post' do
      get :new
      expect(assigns[:post]).to be_a Post
    end

    it 'renders the :new template' do
      get :new
      expect(response).to render_template :new
    end
  end # describe "GET 'new'"
end # describe PostsController


require 'spec_helper'

shared_examples 'an attempt to create an invalid Post' do
  describe 'with an invalid title, the returned PostData instance is' do

    before :each do
      params[:title] = ''
      post :create, post_data: params, blog: blog
      @post = assigns[:post]
    end

    it 'a new record' do
      expect(@post).to be_a_new_record
    end

    it 'is invalid' do
      expect(@post).to_not be_valid
    end

    it 'provides the correct error message' do
      expect(@post.errors.full_messages).to include "Title can't be blank"
    end
  end # describe 'with an invalid title, the returned PostData instance is'
end # shared_examples 'an attempt to create an invalid Post'

# Posts controller dispatches post-specific actions
describe PostsController do
  let(:not_auth_message) { 'You are not authorized to perform this action.' }

  describe :routing.to_s, type: :routing do
    it { expect(get new_post_path).to route_to 'posts#new' }
    it { expect(post posts_path).to route_to 'posts#create' }
    it do
      expect(get post_path('the-title'))
          .to route_to controller: 'posts', action: 'show', id: 'the-title'
    end
    # Can't disable ID-based routing but enable slug-based. This has to be
    # restricted at the controller/DSO level.
    # it { expect(get '/posts/:id').to_not be_routable }
    it { expect(delete post_path(1)).to_not be_routable }
    it do
      expect(get '/posts/some-title/edit')
          .to route_to 'posts#edit', id: 'some-title'
    end
    it do
      expect(put '/posts/some-title')
          .to route_to 'posts#update', id: 'some-title'
    end
  end

  describe :helpers.to_s do
    it { expect(new_post_path).to eq '/posts/new' }
    it { expect(posts_path).to eq '/posts' }
    it { expect(post_path(42)).to eq '/posts/42' }
    it { expect(edit_post_path('some-title')).to eq '/posts/some-title/edit' }
  end

  describe "GET 'new'" do

    context 'for a Registered User' do
      before :each do
        @user = FactoryGirl.create :user_datum
        session[:user_id] = @user.id
        get :new
      end

      after :each do
        session[:user_id] = nil
        @user.destroy
      end

      it 'returns http success' do
        expect(response).to be_success
      end

      it 'assigns a new PostData instance to :post' do
        post = assigns[:post]
        expect(post).to be_a PostData
        expect(post).to be_a_new_record
      end

      it 'renders the :new template' do
        expect(response).to render_template :new
      end
    end # context 'for a Registered User'

    context 'for the Guest User' do
      before :each do
        session[:user_id] = nil
        get :new
      end

      it 'assigns a new PostData instance to :post' do
        expect(assigns[:post]).to be_a_new_record
      end

      it 'redirects to the landing page' do
        expect(response).to be_redirection
        expect(response).to redirect_to root_path
      end

      it 'renders the correct flash error message' do
        expect(flash[:error]).to eq not_auth_message
      end
    end # context 'for the Guest User'
  end # describe "GET 'new'"

  describe "POST 'create'" do

    let(:blog) { BlogData.first.to_param }
    let(:params) { FactoryGirl.attributes_for :post_datum }

    context 'for a Registered User' do
      describe 'with valid parameters' do
        before :each do
          @user = FactoryGirl.create :user_datum
          session[:user_id] = @user.id
          post :create, post_data: params, blog: blog
        end

        after :each do
          session[:user_id] = nil
          @user.destroy
        end

        it 'assigns the :post item as a PostData instance' do
          expect(assigns[:post]).to be_a PostData
        end

        it 'persists the PostData instance corresponding to the :post' do
          expect(assigns[:post]).to_not be_a_new_record
        end

        it 'redirects to the root path' do
          expect(response).to redirect_to root_path
        end

        it 'displays the "Post added!" flash message' do
          expect(request.flash[:success]).to eq 'Post added!'
        end
      end # describe 'with valid parameters'

      it_behaves_like 'an attempt to create an invalid Post'
    end # context 'for a Registered User'

    context 'for the Guest User' do
      before :each do
        session[:user_id] = nil
      end

      describe 'with valid parameters' do
        before :each do
          post :create, post_data: params, blog: blog
        end

        it 'assigns the :post item as a new PostData instance' do
          post = assigns[:post]
          expect(post).to be_a PostData
          expect(post).to be_a_new_record
        end

        it 'redirects to the root path' do
          expect(response).to redirect_to root_path
        end

        it 'renders the correct flash error message' do
          expect(flash[:error]).to eq not_auth_message
        end
      end # describe 'with valid parameters'

      it_behaves_like 'an attempt to create an invalid Post'
    end # context 'for the Guest User'
  end # describe "POST 'create'"

  # Currently, *all* published articles are public, so no branching for that.
  # Whether the requesting user is the author or not is irrelevant to the
  # controller; it just retrieves the article.
  describe "GET 'show'" do
    let(:author) { FactoryGirl.create :user_datum }
    let(:blog) { BlogData.first }
    let(:article) do
      FactoryGirl.create :post_datum,
                         author_name: author.name,
                         pubdate: Chronic.parse('3 PM yesterday')
    end

    context 'for a valid post' do
      before :each do
        get :show, id: article.slug
      end

      it 'responds with an HTTP status of :ok' do
        expect(response).to be_ok
      end

      it 'assigns an object to Post' do
        expect(assigns[:post]).to be_a PostData
      end

      it 'renders the :show template' do
        expect(response).to render_template :show
      end
    end # context 'for a valid post'

    context 'for an invalid post' do
      let(:bad_slug) { 'this-is-a-bogus-article-slug' }
      before :each do
        get :show, id: bad_slug
      end

      it 'responds with an HTTP status of :redirect' do
        expect(response).to be_redirect
      end

      it 'redirects to the root URL' do
        expect(response).to redirect_to root_url
      end

      it 'renders the correct flash error message' do
        expected = [
          'There is no article with an ID of "',
          '"!'].join bad_slug
        expect(flash[:alert]).to eq expected
      end
    end # context 'for an invalid post'
  end # describe "GET 'show'"

  describe "GET 'edit'" do

    context 'for the Guest User' do
      let(:post) { FactoryGirl.create :post_datum }

      before :each do
        get :edit, id: post.title.parameterize
      end

      it 'displays the authorisation-failure flash message' do
        expect(request.flash[:error]).to eq not_auth_message
      end

      it 'redirects to the root path' do
        expect(response).to redirect_to root_path
      end
    end # context 'for the Guest User'

    context 'for a logged-in user' do
      let(:author) { FactoryGirl.create :user_datum }
      let(:post) { FactoryGirl.create :post_datum, author_name: author.name }
      before :each do
        session[:user_id] = author.name.parameterize
      end

      context 'editing his own article' do
        before :each do
          get :edit, id: post.title.parameterize
        end

        it 'returns a status of HTTP ok' do
          expect(response).to be_ok
        end

        it 'renders edit-post template' do
          expect(response).to render_template :edit
        end

        it 'assigns the :post instance to the requested instance' do
          expect(assigns[:post]).to eq post
        end
      end # context 'editing his own article'

      context 'attempting to edit an article authored by another user' do
        let(:user) { FactoryGirl.create :user_datum }
        before :each do
          session[:user_id] = user.name.parameterize
          get :edit, id: post.title.parameterize
        end

        it 'displays the authorisation-failure flash message' do
          expect(request.flash[:error]).to eq not_auth_message
        end

        it 'redirects to the root path' do
          expect(response).to redirect_to root_path
        end
      end # context 'attempting to edit an article authored by another user'
    end # context 'for a logged-in user'
  end # describe "GET 'edit'"
end # describe PostsController

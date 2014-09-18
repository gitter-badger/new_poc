
require 'spec_helper'

require 'post_creator_and_publisher'

# Module DSO contains our Domain Service Objects, aka "interactors".
module DSO
  describe PostCreatorAndPublisher do

    let(:klass) { PostCreatorAndPublisher }
    let(:blog) { BlogData.first.to_param }
    # let(:post_params) { FactoryGirl.attributes_for :post_datum }
    let(:new_draft_params) do
      {
        blog: blog,
        post_data: FactoryGirl.attributes_for(:post_datum,
                                              :new_post,
                                              :draft_post)
      }
    end
    let(:new_public_params) do
      {
        blog: blog,
        post_data: FactoryGirl.attributes_for(:post_datum,
                                              :new_post,
                                              :public_post)
      }
    end
    let(:saved_draft_params) do
      {
        blog: blog,
        post_data: FactoryGirl.attributes_for(:post_datum,
                                              :saved_post,
                                              :draft_post)
      }
    end
    let(:saved_public_params) do
      {
        blog: blog,
        post_data: FactoryGirl.attributes_for(:post_datum,
                                              :saved_post,
                                              :public_post)
      }
    end
    let(:draft_post_params) do
      [
        new_draft_params,
        saved_draft_params
      ]
    end
    let(:public_post_params) do
      [
        new_public_params,
        saved_public_params
      ]
    end
    let(:all_params) { draft_post_params + public_post_params }
    # let(:params) { { post_data: post_params, blog: blog } }

    describe 'succeeds when called with valid parameters, such that' do
      it 'no error is raised' do
        all_params.each do |params|
          expect { klass.run! params: params }.to_not raise_error
        end
      end

      it 'returns a Post instance' do
        all_params.each do |params|
          expect(klass.run! params: params).to be_a Post
        end
      end

      describe 'returns a Post instance that has' do
        # let(:post) { klass.run! params: params }

        it 'the correct title for each valid parameter set' do
          all_params.each do |params|
            post = klass.run! params: params
            expect(post.title).to eq params[:post_data][:title]
          end
        end

        it 'the correct body for each valid parameter set' do
          all_params.each do |params|
            post = klass.run! params: params
            expect(post.body).to eq params[:post_data][:body]
          end
        end

        it 'the correct image URL for each valid parameter set' do
          all_params.each do |params|
            post = klass.run! params: params
            expect(post.image_url).to eq params[:post_data][:image_url]
          end
        end

        context 'for public-post parameters' do
          it 'been published' do
            public_post_params.each do |params|
              post = klass.run! params: params
              expect(post).to be_published
            end
          end
        end # context 'for public-post parameters'

        context 'for draft-post parameters' do
          it 'not been published' do
            draft_post_params.each do |params|
              post = klass.run! params: params
              expect(post).not_to be_published
            end
          end
        end # context 'for draft-post parameters'
      end # describe 'returns a Post instance that has'
    end # describe 'succeeds when called with valid parameters, such that'

    describe 'reports errors when called with' do

      describe 'both an empty post body and empty image URL, so that' do
        let(:post) do
          saved_public_params[:post_data][:body] = ''
          saved_public_params[:post_data][:image_url] = ''
          klass.run! params: saved_public_params
        end

        it 'the post reports itself as invalid' do
          expect(post).to_not be_valid
        end

        it 'the expected errors are shown to have been detected' do
          format_str = '%s must be present if %s is missing or blank'
          body_message = format format_str, 'Body', 'image url'
          image_message = format format_str, 'Image url', 'body'
          expect(post).to have(2).error_messages
          expect(post.error_messages).to include body_message
          expect(post.error_messages).to include image_message
        end
      end # describe 'both an empty post body and empty image URL, so that'
    end # describe 'fails when called with'
  end # describe DSO::PostCreatorPublisher
end # module DSO

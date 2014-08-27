
require 'spec_helper'

require 'post_updater'

# Module DSO contains our Domain Service Objects, aka "interactors".
module DSO
  describe PostUpdater do
    let(:author_datum) { FactoryGirl.create :user_datum }
    let(:author) { CCO::UserCCO.to_entity author_datum }
    let(:post_datum) do
      FactoryGirl.create :post_datum, author_name: author.name
    end
    let(:post) { CCO::PostCCO.to_entity post_datum }
    let(:post_data) do
      {
        title:      post.title,
        image_url:  post.image_url,
        slug:       post.slug,
        body:       "Updated by *spec*!\n\n" + post.body
      }
    end

    describe 'succeeds when called with' do

      it 'a complete set of valid attributes' do
        result = PostUpdater.run user: author, post: post, post_data: post_data
        expect(result).to be_valid
        entity = result.result
        post_data.each do |attr, value|
          expect(entity.send attr).to eq value
        end
      end

      describe 'a partial set of valid attributes, including' do
        after :each do
          result = PostUpdater.run user: author,
                                   post: post,
                                   post_data: post_data
          expect(result).to be_valid
          expect(result.errors).to be_empty
        end

        # TBD: Should title/slug be updateable?
        describe 'the single attribute' do
          [:title, :slug, :image_url, :body].each do |attr|

            xit ":#{attr}" do
              @data = {}
              @data[attr] = post_data[attr]
            end
          end
        end # describe 'the single attribute'

        describe 'all valid attributes EXCEPT for' do
          [:title, :slug, :image_url, :body].each do |excluded|

            xit ":#{excluded}" do
              @data = Marshal.load(Marshal.dump post_data)
              @data.delete excluded
            end
          end
        end # describe 'all valid attributes EXCEPT for'
      end # describe 'a partial set of valid attributes, including'
    end # describe 'succeeds when called with'
  end # describe DSO::PostUpdater
end # module DSO

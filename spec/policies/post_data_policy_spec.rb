
require 'spec_helper'

describe PostDataPolicy do
  subject { PostDataPolicy }
  let(:guest_user) { UserData.first }
  let(:registered_user) { FactoryGirl.build :user_datum }
  let(:author) { FactoryGirl.build :user_datum }
  let(:instance) { FactoryGirl.create :post_datum, author_name: author.name }

  permissions :create? do

    it 'prohibits the Guest User from invokuing the :create action' do
      expect(subject).not_to permit(guest_user, instance)
    end

    it 'permits a Registered User to invoke the :create action' do
      expect(subject).to permit(registered_user, instance)
    end
  end # permissions :create?

  permissions :edit? do
    describe 'prohibits invoking the :edit action by' do

      it 'the Guest User' do
        expect(subject).not_to permit(guest_user, instance)
      end

      it 'a Registered User other than the author' do
        expect(subject).not_to permit(registered_user, instance)
      end
    end # describe 'prohibits invoking the :edit action by'

    it 'permits the post author to invoke the :edit action' do
      expect(subject).to permit(author, instance)
    end
  end # permissions :edit?

  permissions :update? do
    describe 'prohibits invoking the :update action by' do

      it 'the Guest User' do
        expect(subject).not_to permit(guest_user, instance)
      end

      it 'a Registered User other than the author' do
        expect(subject).not_to permit(registered_user, instance)
      end
    end # describe 'prohibits invoking the :update action by'

    it 'permits the post author to invoke the :update action' do
      expect(subject).to permit(author, instance)
    end
  end # permissions :update?
end # describe PostDataPolicy

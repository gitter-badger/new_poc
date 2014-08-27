
require 'spec_helper'

shared_examples 'an entity and model with same main attrs' do |token|
  let(:impl) { FactoryGirl.create :user_datum }
  let(:entity) { CCO::UserCCO.to_entity impl, current_session: token }
  describe 'has the correct attributes for' do

    [:name].each do |sym| # , :email, :profile, :slug].each do |sym|
      it sym.to_s do
        expect(entity.send sym).to eq impl.send(sym)
      end
    end # [...].each do |sym|
  end # describe 'has the correct attributes for'
end # shared_examples 'an entity and model with same main attrs'

example_description = 'an entity with expected attributes and session token'
shared_examples example_description do |token|
  context_description = if token
                          'with a specified session token'
                        else
                          'without specifying a session token'
                        end

  context context_description do
    it_behaves_like 'an entity and model with same main attrs'
  end # context context_description

  modifier = 'not' unless token
  it "reports as #{modifier} being authenticated".squeeze do
    impl = FactoryGirl.build :user_datum
    entity = CCO::UserCCO.to_entity impl, current_session: token
    expected = !token.nil?
    expect(entity.authenticated?).to be expected
  end
end # shared_examples example_description

# ############################################################################ #
# ############################################################################ #
# ############################################################################ #

# Module for cross-layer conversion objects.
module CCO
  # CCO for Users. Does not (presently) subclass Base.
  describe UserCCO do

    describe :to_entity do
      let(:impl) { FactoryGirl.create :user_datum }

      descr = 'an entity with expected attributes and session token'
      it_behaves_like descr

      it_behaves_like descr, 'SESSION_TOKEN'
    end # describe :to_entity

    describe :from_entity do
      it_behaves_like 'an entity and model with same main attrs'

      it 'produces a new, unsaved record' do
        attribs = FactoryGirl.attributes_for :user_datum
        attribs[:slug] ||= 'some-random-slug'
        entity = User.new attribs
        impl = CCO::UserCCO.from_entity entity
        expect(impl).to be_a_new_record
      end
    end # describe :from_entity
  end # describe UserCCO
end # module CCO

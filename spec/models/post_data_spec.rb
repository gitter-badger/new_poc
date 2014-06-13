# == Schema Information
#
# Table name: post_data
#
#  id         :integer          not null, primary key
#  title      :string(255)      not null
#  body       :text
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe PostData do
  let(:klass) { PostData }

  describe 'supports initialisation' do

    it 'with no parameters' do
      expect { klass.new }.to_not raise_error
    end

    it 'with a title parameter string only' do
      expect { FactoryGirl.create :post_datum, body: nil }.to_not raise_error
    end

    it 'with both title and body parameter strings' do
      expect { FactoryGirl.build :post_datum }.to_not raise_error
    end
  end # describe 'supports initialisation'

  describe 'reports validation correctly, showing that' do

    it 'an instance with no title violates a database constraint' do
      obj = FactoryGirl.build :post_datum, title: nil
      error = ActiveRecord::StatementInvalid
      message = \
          /SQLite3::ConstraintException: post_data.title may not be NULL.*/
      expect { obj.save }.to raise_error error, message
    end

    it 'an instance with a title but no body is valid' do
      obj = FactoryGirl.build :post_datum, body: nil
      expect(obj).to be_valid
    end

    it 'an instance with both title and body is valid' do
      expect(FactoryGirl.build :post_datum).to be_valid
    end
  end # describe 'reports validation correctly, showing that'

  # little point proving that save/reload work, yes? currently no other
  # meaningful tests
end
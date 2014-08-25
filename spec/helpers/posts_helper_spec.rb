
require 'spec_helper'

shared_examples 'post form-attributes helper' do |form_name|
  describe "#{form_name}_form_attributes" do
    subject do
      message = "#{form_name}_form_attributes"
      helper.send message
    end

    it 'returns a Hash' do
      expect(subject).to be_a Hash
    end

    describe 'has top-level keys for' do
      after :each do
        expect(subject).to have_key RSpec.current_example.description.to_sym
      end

      it :html do
      end

      it :role do
      end

      it :url do
      end
    end # describe 'has top-level keys for'

    describe 'has an :html sub-hash that contains the correct values for' do
      it 'the :id key' do
        expect(subject[:html][:id]).to eq form_name
      end

      it 'the :class key' do
        classes = subject[:html][:class].split(/\s+/)
        expect(classes).to include 'form-horizontal'
        expect(classes).to include form_name
      end
    end # describe 'has an :html sub-hash that contains the correct values for'

    it 'has a :role item with the value "form" as an ARIA instruction' do
      expect(subject[:role]).to eq 'form'
    end

    it 'has a :url item with the value returned from the posts_path helper' do
      expected = helper.posts_path
      expect(subject[:url]).to eq expected
    end
  end # describe "#{form_name}_form_attributes"
end

describe PostsHelper do
  it_behaves_like 'post form-attributes helper', 'new_post'

  it_behaves_like 'post form-attributes helper', 'edit_post'
end # describe PostsHelper

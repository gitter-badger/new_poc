
require 'support/shared_examples/helpers/menu_spec_helper_functions'

description = 'a menu containing appropriate items for a Registered User'
shared_examples description do |current_user, menu_sym|

  context "when called passing in :#{menu_sym} for a Registered User" do
    let(:built_menu) { build_menu_for menu_sym, current_user }
    let(:container) { Nokogiri.parse built_menu }
    separator_style = separator_style_for menu_sym

    describe 'contains a top-level `ul` element that' do
      let(:current_el) { container.elements.first }

      it 'contains 4 child elements' do
        expect(current_el).to have(4).children
      end

      it %w(has as its first child element an `li` element whose only child is
            an `a` element with the text "Home" that links to the root
            path).join(' ') do
        it_behaves_like_a_menu_list_item text: 'Home',
                                         index: 0,
                                         path: root_path,
                                         current_el: current_el
      end

      it %w(has as its second child element an `li` element whose only child
            is an `a` element with the text "New Post" that links to the
            new-post path).join(' ') do
        it_behaves_like_a_menu_list_item text: 'New Post',
                                         index: 1,
                                         path: new_post_path,
                                         current_el: current_el
      end

      it %w(has as its third child element an `li` element which serves as a
            vertical spacer).join(' ') do
        it_behaves_like_a_menu_separator index: 2,
                                         current_el: current_el,
                                         style: separator_style
      end

      it %w(has as its fourth child element an `li` element whose only child is
            an `a` element with the text "Log out" that links to the
            current session path using the HTTP DELETE action, and informs
            search engines not to follow the link).join(' ') do
        it_behaves_like_a_menu_list_item text: 'Log out',
                                         index: 3,
                                         path: '/sessions/current',
                                         current_el: current_el,
                                         data_method: 'delete'
      end
    end # describe 'contains a top-level `ul` element that'
  end # context "when called passing in :#{menu_sym} for a Registered User"

  current_user.destroy
end # shared_examples 'a menu containing ... items for a Registered User'

require 'pundit'
require 'pundit_authorizer'

module DSO
  # Authorises the user to perform the action on an internally-generated, dummy
  # SessionData instance. AFAICT, this should exactly reproduce the effects of
  # the SessionsController#authorise_current_user method below, except that it
  # doesn't seem to. Figuring out *why* is the current challenge.
  class ActiveSessionUserAuthoriser < ActiveInteraction::Base
    interface :current_user
    interface :session_datum
    string :action
    include Pundit

    # Compare this code to the `authorise_current_user` method in the controller
    # below, then review the code accompanying PR 136 for Pundit; see
    # https://github.com/billychan/pundit/commit/2c2f9a1 -- what am I missing?
    def execute
      ap "Entering #execute: session_datum has ID #{session_datum.object_id}"
      active_user = policied_user
      # session_datum = SessionData.new id: 0
      update_active_policy active_user, session_datum
      ap "After #update_active_policy, session_datum has ID #{session_datum.object_id}"
      # HACK: Calling `PunditAuthorizer.new` directly gives an error
      #       'DSO::ActiveSessionUserAuthoriser::PunditAuthorizer not found'
      #       Why? Calling it from the debugger Just Works here.
      # binding.pry
      auth_class = self.class.parent.parent::PunditAuthorizer
      authorizer = auth_class.new active_user, session_datum
      authorizer.authorize_on action
      ap "After authorize_on, session_datum has ID #{session_datum.object_id}"
      session_datum
    end

    private

    def policied_user
      user = current_user
      user.instance_eval do
        def self.policy_class
          SessionDataPolicy
        end
      end
      binding.pry
      user
    end

    def update_active_policy(active_user, session_datum)
      @policy = Pundit.policy(active_user, session_datum)
    end
  end # class DSO::ActiveSessionUserAuthoriser
end # module DSO

# ############################################################################ #
# ############################################################################ #
# ############################################################################ #

# SessionsController: actions related to Sessions (logging in and out)
class SessionsController < ApplicationController
  def new
    # authorise_current_user
    session_datum = SessionData.new id: 0
    ap "Third line of #new: object ID is #{session_datum.object_id}"
    @session = DSO::ActiveSessionUserAuthoriser
        .run! current_user: current_user,
              session_datum: session_datum,
              action: 'new'
    ap "returning from #new, @session ID is #{@session.object_id}"
    @session
  end

  def create
    requesting_user = UserData.find_by_name params[:name]
    authorise_current_user
    if user_can_sign_in requesting_user, params[:password]
      setup_successful_login requesting_user
    else
      setup_failed_login requesting_user
    end
  end

  def destroy
    authorise_current_user
    update_current_user_id
    redirect_to root_url, flash: flash_for_successful_logout
  end

  private

  # TODO: This should be a DSO, or at least a self-contained class.
  def authorise_current_user
    active_user = user_with_policy_class
    update_active_policy active_user
    authorize active_user
  end

  def flash_for_failed_login
    { alert: 'Invalid user name or password' }
  end

  def flash_for_successful_login
    { success: 'Logged in!' }
  end

  def flash_for_successful_logout
    { success: 'Logged out!' }
  end

  def setup_failed_login(_user)
    redirect_to new_session_url, flash: flash_for_failed_login
  end

  def setup_successful_login(user)
    update_current_user_id user.id
    redirect_to root_url, flash: flash_for_successful_login
  end

  def update_active_policy(active_user)
    @policy = Pundit.policy(active_user, SessionData.new(id: 0))
  end

  def update_current_user_id(id = UserData.first.id)
    session[:user_id] = id
  end

  def user_can_sign_in(user, password)
    user && user.authenticate(password)
  end

  def user_with_policy_class
    user = current_user       # remember, #current_user is a query method
    user.instance_eval do
      def self.policy_class
        SessionDataPolicy
      end
    end
    user
  end
end

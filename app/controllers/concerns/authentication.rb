# frozen_string_literal: true

# The Authentication concern provides methods for authenticating users and managing sessions.
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    # Skip authentication for the given actions.
    # @ param [Array<Symbol>] options The actions to skip authentication for.
    # @ return [void]
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    # Check if the user is authenticated by either resuming a session or redirecting to the sign in page.
    # @ return [Boolean] True if the user is authenticated, otherwise false.
    def authenticated?
      resume_session
    end

    # Require authentication by either resuming a session or redirecting to the sign in page.
    # @ return [void]
    def require_authentication
      resume_session || request_authentication
    end

    # Resume a session from the session cookie.
    # @ return [Session, nil] The session if found, otherwise nil.
    def resume_session
      Current.session ||= find_session_by_cookie
    end

    # Find a session by the session cookie.
    # @ return [Session, nil] The session if found, otherwise nil.
    def find_session_by_cookie
      Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    # Redirect the user to the sign in page.
    # Before redirecting, store the current URL in the return_to_after_authenticating session variable.
    # @ return [void]
    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end

    # Get the URL to redirect to after authentication from the return_to_after_authenticating session variable.
    # @ return [String] The URL to redirect to after authentication.
    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    # Start a new session for the user.
    # @ param [User] user The user to start a session for.
    # @ return [void]
    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    # Terminate the current session and delete the session cookie.
    # @ return [void]
    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
    end

    # Clear the site data when the user logs out to prevent data leakage via the browsers back/forward cache.
    # @ return [void]
    def clear_site_data
      response.headers["Clear-Site-Data"] = '"cache","storage"'
    end
end

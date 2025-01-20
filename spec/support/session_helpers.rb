# frozen_string_literal: true

# Authentication helpers for feature specs
module SessionHelpers
  # Sign in as the given user by setting the session cookie
  # @param [User] the user to sign in as
  # @return [void]
  def sign_in_as(user)
    Current.session = user.sessions.create!

    ActionDispatch::TestRequest.create.cookie_jar.tap do |cookie_jar|
      cookie_jar.signed[:session_id] = Current.session.id
      page.driver.browser.set_cookie(
        "session_id=#{cookie_jar[:session_id]}; path=/; HttpOnly"
      )
    end
  end

  # Sign out by destroying the current session and clearing the session cookie
  # @return [void]
  def sign_out
    Current.session&.destroy!
    page.driver.browser.clear_cookies
  end
end

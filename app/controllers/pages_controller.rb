class PagesController < ApplicationController
  allow_unauthenticated_access only: :landing

  def landing; end
end

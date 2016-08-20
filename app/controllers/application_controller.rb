class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # temporary hax
  def current_user
    User.first_or_initialize(username: 'ebington')
  end
end

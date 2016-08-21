class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # temporary hax
  def current_user
    User.find_by_uuid(session['session_token'])
  end

  def login_required
    redirect_to root_path, notice: 'You need to log in first' unless current_user
  end
end

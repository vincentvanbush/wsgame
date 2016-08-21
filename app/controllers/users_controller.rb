class UsersController < ApplicationController
  def login
    @user = User.find_or_initialize_by(user_params)
    @user.uuid = SecureRandom.uuid
    if @user.save
      session['session_token'] = @user.uuid
      redirect_to rooms_path, notice: 'You have been logged in!'
    else
      redirect_to request.referer, flash: { error: @user.errors.full_messages.to_sentence }
    end
  end

  private

  def user_params
    params.require(:user).permit(:username)
  end
end

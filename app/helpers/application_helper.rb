module ApplicationHelper
  delegate :current_user, to: :controller
end

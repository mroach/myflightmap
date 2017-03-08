class Admin::AdminController < ApplicationController
  before_action :authorize_user!

  def authorize_user!
    if !current_user.admin?
      render(file: "#{Rails.root}/public/403.html", status: :forbidden, layout: false)
    end
  end
end

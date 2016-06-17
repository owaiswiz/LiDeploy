class AdminController < ApplicationController
  before_action :authenticate_user!,:admin
  def index
  end
  private
  def admin
    if current_user.admin == true

    else
      redirect_to instances_path and return
    end
  end
end

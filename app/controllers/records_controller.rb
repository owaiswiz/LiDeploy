class RecordsController < ApplicationController
  def index
    @domains = current_user.domains
    @newdomain = Domain.new
    @instances = current_user.instances
  end
  def create
    redirect_to domains_path
  end
end

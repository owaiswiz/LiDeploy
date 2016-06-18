class AdminController < ApplicationController
  before_action :authenticate_user!,:admin
  def index
    @page = "index"
    @instancescount = Instance.all.size
    @ticketscount = Ticket.all.size
    @userscount = User.all.size
    @domainscount = Domain.all.size
  end

  def instances
    @page = "instances"
    @instances = Instance.all
    render 'index'
  end

  def tickets
    @page = "tickets"
    @tickets = Ticket.all
    if params[:ticketid].nil?
      params[:ticketid] = @tickets.first.id
    end
    @ticket = @tickets.find(params[:ticketid])
    @replies = @ticket.replies
    @newreply = Reply.new
    render 'index'
  end

  def users
    @page = "users"
    @users = User.all
    render 'index'
  end
  private
  def admin
    if current_user.admin == true

    else
      redirect_to instances_path and return
    end
  end
end

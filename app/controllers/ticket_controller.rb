class TicketController < ApplicationController
  before_action :authenticate_user!
  def index
    @tickets = Ticket.where(user_id: current_user.id)
  end

  def new
    @ticket = Ticket.new
  end
  def create
    @ticket = Ticket.new(ticket_params)
    if @ticket.save
      render :index
    end
  end
  private
  def ticket_params
    params.require(:ticket).permit(:title,:message,:status)
  end
end

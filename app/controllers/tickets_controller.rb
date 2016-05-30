class TicketsController < ApplicationController
  before_action :authenticate_user!
  def index
    if params[:ticketid] != "newticket"
      @tickets = Ticket.where(user_id: current_user.id)
      @user = User.find_by(id: current_user.id)
      if @tickets.first.nil?
        @tickets = nil
        @newticket = Ticket.new
        params[:ticketid] = "newticket"
      else
        if params[:ticketid].nil?
          params[:ticketid] = @tickets.first.id
        end
        @ticket = @tickets.find_by(user_id: current_user.id,id: params[:ticketid])
        if @ticket.nil?
          flash.now[:alert] = "Invalid Ticket ID"
        end
      end
    else
      @newticket= Ticket.new
    end
  end

  def new
    @ticket = Ticket.new
  end
  def create
    @ticket = Ticket.new(ticket_params)
    @ticket.user_id = current_user.id
    @ticket.status = "open"
    if @ticket.save
      redirect_to view_tickets_path
    end
  end
  private
  def ticket_params
    params.require(:ticket).permit(:title,:message,:status)
  end
end

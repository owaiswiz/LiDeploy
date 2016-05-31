class TicketsController < ApplicationController
  before_action :authenticate_user!
  def index
    @tickets = Ticket.where(user_id: current_user.id).order(updated_at: 'DESC')
    @user = User.find_by(id: current_user.id)
    if @tickets.first.nil?
      @tickets = nil
      @newticket = Ticket.new
      params[:ticketid] = "newticket"
    else
      if params[:ticketid].nil?
        params[:ticketid] = @tickets.first.id
      end
    end
    if params[:ticketid] != "newticket"
      @ticket = @tickets.find_by(user_id: current_user.id,id: params[:ticketid])
        if @ticket.nil?
          flash.now[:alert] = "Invalid Ticket ID"
        else
          @replies = @ticket.replies
          @newreply = Reply.new
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
  def addreply
    @ticket = Ticket.find_by(user_id: current_user.id,id:params[:ticketid])
    @reply = @ticket.replies.create(reply_params)
    @reply.from = current_user.username
    if @reply.save
      if params[:status] == "Close Ticket"
        @ticket.update_attributes(:status => "closed")
      elsif @ticket.status == "closed"
        @ticket.update_attributes(:status => "open")
      end
      redirect_to tickets_path
    end
  end
  private
  def ticket_params
    params.require(:ticket).permit(:title,:message,:status)
  end
  def reply_params
    params.require(:reply).permit(:reply)
  end
end

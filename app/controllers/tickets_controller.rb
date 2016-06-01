class TicketsController < ApplicationController
  before_action :authenticate_user!
  def index
    @user = User.find_by(id: current_user.id)
    if params[:ticketid].nil?
      @tickets = Ticket.where(user_id:current_user.id,:status => params[:status])
      if @tickets.first.nil?
        @tickets = nil
        params[:ticketid] = "newticket"
      else
        params[:ticketid] = @tickets.first.id
      end
    end
    if params[:ticketid] != "newticket"
      @ticket = Ticket.find_by(user_id: current_user.id,id:params[:ticketid])
      if @ticket.nil?
        flash[:alert] = "Invalid Ticket ID"
        redirect_to view_tickets_path and return
      else
        params[:status] = @ticket.status
        @replies = @ticket.replies
        @newreply = Reply.new
      end
      @tickets = Ticket.where(user_id:current_user.id,:status => @ticket.status)
    else
      if params[:status].nil?
        params[:status] = "open"
      else

      end
      @tickets = Ticket.where(user_id: current_user.id,:status => params[:status])
      if @tickets.first.nil?
        @tickets=nil
      end
      @newticket= Ticket.new
    end
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
    if params[:reply][:reply].gsub(/\s+/,'').length > 0
      @reply = @ticket.replies.create(reply_params)
      @reply.from = current_user.username
      if @reply.save
        flash[:notice] = "Reply Submitted"
        SendTicketEmailJob.set(wait: 20.seconds).perform_later(@reply)
      else
        flash[:alert] = "Error occurred while submitting reply."
      end
    end
    if params[:status] == "Close Ticket"
      @ticket.update_attributes(:status => "closed")
      flash[:notice1] = "Ticket Closed"
    elsif @ticket.status == "closed"
      @ticket.update_attributes(:status => "open")
      flash[:notice1] = "Ticket Opened"
    end
    redirect_to ticket_path

  end
  private
  def ticket_params
    params.require(:ticket).permit(:title,:message,:status)
  end
  def reply_params
    params.require(:reply).permit(:reply)
  end
end

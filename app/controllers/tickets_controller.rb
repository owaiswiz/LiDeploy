class TicketsController < ApplicationController
  before_action :authenticate_user!
  def index
    if params[:ticketid].nil?
      @tickets = current_user.tickets.where(status: params[:status])
      if @tickets.first.nil?
        @tickets = nil
        params[:ticketid] = "newticket"
      else
        params[:ticketid] = @tickets.first.id
      end
    end
    if params[:ticketid] != "newticket"
      @ticket = current_user.tickets.find(params[:ticketid])
      if @ticket.nil?
        flash[:alert] = "Invalid Ticket ID"
        redirect_to view_tickets_path and return
      else
        params[:status] = @ticket.status
        @replies = @ticket.replies
        @newreply = Reply.new
      end
      @tickets = current_user.tickets.where(status: @ticket.status)
    else
      if params[:status].nil?
        params[:status] = "open"
      end
      @tickets = current_user.tickets.where(status: params[:status])
      if @tickets.first.nil?
        @tickets=nil
      end
      @newticket= Ticket.new
    end
  end

  def create
    ticket = current_user.tickets.new(ticket_params)
    ticket.status = "open"
    ticket.last_reply_from,ticket.created_by = [current_user.username] * 2
    if ticket.save
      flash[:notice] = "Ticket Created"
      redirect_to view_tickets_path
    end
  end

  def addreply
    unless current_user.admin
      ticket = current_user.tickets.find_by(id:params[:ticketid])
    else
      ticket = Ticket.find(params[:ticketid])
    end
    if params[:reply][:reply].gsub(/\s+/,'').length > 0
      reply = ticket.replies.new(reply_params)
      reply.from = current_user.username
      if reply.save
        ticket.update_attributes(last_reply_from: current_user.username)
        flash[:notice] = "Reply Submitted"
        if reply.from != ticket.created_by
          SendTicketEmailJob.set(wait: 20.seconds).perform_later(reply)
        end
      else
        flash[:alert] = "Error occurred while submitting reply."
      end
    end
    if params[:status] == "Close Ticket"
      ticket.update_attributes(:status => "closed")
      flash[:notice1] = "Ticket Closed"
    elsif ticket.status == "closed"
      ticket.update_attributes(:status => "open")
      flash[:notice1] = "Ticket Opened"
    end
    if current_user.admin
      redirect_to "/admin/ticket/#{ticket.id}"
    else
      redirect_to ticket_path
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

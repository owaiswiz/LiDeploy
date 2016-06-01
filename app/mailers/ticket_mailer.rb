class TicketMailer < ApplicationMailer
  def newreply(reply)
    @reply = reply
    @user = User.find_by(id: @reply.ticket.user_id)
    mail(to: @user.email, subject: "New Reply on Support Ticket[ID: #{@reply.ticket.id}-#{@reply.id}] at LiDeploy")
  end

end

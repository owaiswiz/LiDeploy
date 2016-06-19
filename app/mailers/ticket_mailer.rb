class TicketMailer < ApplicationMailer
  def newreply(reply)
    @reply = reply
    @mticket = @reply.ticket
    mail(to: @mticket.user.email, subject: "New Reply on Support Ticket[ID: #{@mticket.id}-#{@reply.id}] at LiDeploy")
  end
end

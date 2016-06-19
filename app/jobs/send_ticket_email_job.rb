class SendTicketEmailJob < ActiveJob::Base
  queue_as :default

  def perform(replyobj)
    TicketMailer.newreply(replyobj).deliver_later
  end
end

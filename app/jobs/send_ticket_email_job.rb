class SendTicketEmailJob < ActiveJob::Base
  queue_as :default

  def perform(reply)
    # Do something later
    @reply = reply
    TicketMailer.newreply(@reply).deliver_later
  end
end

class PasswordMailer < ApplicationMailer
  def send_password(instance)
    user = User.find_by(id: instance.user_id)
    @instance = instance
    mail(to: user.email, subject: "Login Details for Instance: #{instance.name}")
  end
end

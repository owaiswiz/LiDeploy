class PasswordMailer < ApplicationMailer
  def send_password(instance)
    @createdinstance = instance
    mail(to: instance.user.email, subject: "Login Details for Instance: #{instance.name}")
  end
end

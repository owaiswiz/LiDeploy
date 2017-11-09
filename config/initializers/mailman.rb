require Rails.root.join('app','models','instance.rb')
Mailman.config.pop3 = {
  server: 'poppro.zoho.com',port: 995,ssl: true,
  username: "<%= ENV['SMTP_USERNAME']%>",
  password: "<%= ENV['SMTP_PASSWORD']%>"
}
Mailman.config.poll_interval = 40
Mailman::Rails.receive do
  subject(/Your New Droplet:/) do
    begin
      name,ip,password = message.body.decoded.match(/Droplet Name: (.*)\nIP Address: (.*)\n.*\nPassword: (.*)/).captures
      instances = Instance.where(name: name,ip_address: ip,password: nil)
      instances = Instance.where(:name => name,:password => nil) if instances.blank?
      i=0
      found = 0
      while found == 0 && i < instances.length  do
        instance = instances[i];
        if instance.ip_address == nil || instance.ip_address == ip
          found=1
          instance.update_attributes(:password => password)
          PasswordMailer.send_password(instance).deliver_now
        else
          i=i+1;
        end
      end
    rescue => e
      Rails.logger.info "#{e}"
    end
  end
end

# ![LiDeploy](https://github.com/owaiswiz/LiDeploy/raw/master/app/assets/images/Lideploylogo.png "Logo Title Text 1") 
#### _A DigitalOcean Reseller written with Ruby on Rails utilizing [droplet_kit](https://github.com/digitalocean/droplet_kit)_
##### Live Demo - https://lideploy.herokuapp.com

## Supports
1. Creating/Deleting/Starting/Shutting Down instance
2. Renewing/Resizing instance
3. Creating/Managing different kinds of DNS Records (A,AAA,CNAME,TXT,SRV,MX)
4. Creating Support Tickets
5. Admin panel at /admin - only accessible by user which has admin attribute true (use irb to do this)
## Installation
Following things need to be done to ensure proper execution:
* Set Environment variable `SECRET_KEY_BASE` to a secret key(generate via `rake secret`)
* Set Environment variable `DO_SECRET_KEY` to your DigitalOcean API Key
* Set Environment variable `SMTP_USERNAME` and `SMTP_PASSWORD` to your SMTP server's credential (used for sending emails - password resets, confirmation emails, etc.)
* Execute `rake db:setup` or `rake db:migrate` - To Create Database and apply pending migrations
* Execute `rake assets:precompile` - To precompile assets (necessary if you are running in production and getting a lot of 404s, make sure `RAILS_ENV=production` before running this command)
* Update the `config/database.yml` file according to your Database credentials
* Update `config/secrets.yml`
  * Change `app_host` according to the domain name your application is running on. This is the domain which PayPal posts the payment confirmation to.
  * `app_host` in development can be anything but if you wish to test Paypal integration, make sure you have a hostname that is reachable from the internet (use ngrok)
  * Change `paypal_host` in productioon to `https://www.paypal.com` if you are sure everything else is working properly
* Execute `rake mailman:start` 
  * To start mailman in background in order to listen to incoming mails such as password's email from DO.
  * Make sure you correctly specify your `POP3` email credential inside `config/initializers/mailman.rb` - by default it is the same as your `SMTP` credentials
  * Make sure that DigitalOcean is successfully sending you emails containing the instance's password to the email address specified above
  * We then listen for these kinds of email and match them to see if they belong to any instance that a user recently created, if they do match, we send a email with the instance password and other details to the user's email
* Execute `rake bin/delayed_job` - To start delayed_job in background in order to send new mail in background incase of reply to a ticket.

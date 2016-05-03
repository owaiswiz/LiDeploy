class SessionsController < Devise::SessionsController

  #after_sign_in_path_for is called by devise
  def after_sign_in_path_for(user)
   "/instances/" #adjust the returned path as needed
end
end

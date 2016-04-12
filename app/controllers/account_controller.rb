class AccountController < ApplicationController
	before_action :authenticate_user!
	before_filter :ensure_trailing_slash, :only => :index
	def new
	end
	def index
	end

end

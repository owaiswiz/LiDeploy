class InstancesController < ApplicationController
	def index
	 @instances = Instance.find_by(user_id: current_user.id)
	end

	def new
		@instance = Instance.new
	end

	def show
		#
	end

	def create
		user_id = current_user.id
		#@instance = Instance.create(user_id: user_id,name: name,instanceid: f.id,region: f.region.name,size: f.size,memory: f.memory,vcpus: f.vcpus,disk: f.disk,image: f.image.name)
		@instance= Instance.new(instance_params)
		@instance.user_id = user_id
		if @instance.save
			redirect_to @instance.paypal_url(instance_path(@instance),@instance)
		end
	end

	def destroy
		@instance = Instance.find_by(instanceid: 13158189)
		client = DropletKit::Client.new(access_token: @instance.api_key)
		client.droplets.delete(id: @instance.instanceid)
	end

	protect_from_forgery except: [:hook]
	  def hook
	    params.permit! # Permit all Paypal input params
	    status = params[:payment_status]
	    if status == "Completed"
	      @instance = Instance.find params[:invoice]
				if @instance.status != "Created"
					@instance.update_attributes notification_params: params, transaction_id: params[:txn_id], purchased_at: Time.now
					current_do_key = ENV["DO_SECRET_KEY"]
					client = DropletKit::Client.new(access_token: current_do_key)
					droplet = DropletKit::Droplet.new(name: @instance.name,region: @instance.region,size: @instance.size,image: @instance.image)
					@created = client.droplets.create(droplet)
					@instance.update_attributes(:instanceid => @created.id,:status => "Created",:api_key => current_do_key,:expires => Time.now+@instance.duration.months)
				else
					flash[:notice] = "Instance Already Created"
				end
			else
				flash[:notice] = "Payment Not Completed.Please Contact us at support@lideploy.com for further help"
			end

	    render nothing: true
	  end

	private
	def instance_params
		params.require(:instance).permit(:name,:region,:image,:size,:duration)
	end

end

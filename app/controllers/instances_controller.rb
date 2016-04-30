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
		@drop = Instance.new
		@drop = Instance.find_by(instanceid: 13158189)
		client = DropletKit::Client.new(access_token: 'bfffb539a41beaa052846fa90735faabf80d33d406b51b074a7c02b2e64a96cc')
		client.droplets.delete(id: @drop.instanceid)
	end

	protect_from_forgery except: [:hook]
	  def hook
	    params.permit! # Permit all Paypal input params
	    status = params[:payment_status]
			instid = params[:]
	    if status == "Completed"
	      @instance = Instance.find params[:id]
				client = DropletKit::Client.new(access_token: 'bfffb539a41beaa052846fa90735faabf80d33d406b51b074a7c02b2e64a96cc')
				droplet = DropletKit::Droplet.new(name: @instance.name,region: @instance.region,size: @instance.size,image: @instance.image)
				@instance = client.droplets.create(droplet)
			else
				flash[:notice] = "failed"
			end

	    render nothing: true
	  end

	private
	def instance_params
		params.require(:instance).permit(:name,:region,:image,:size)
	end
end

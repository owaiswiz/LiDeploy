class InstancesController < ApplicationController
	def index
	 @instances = Instance.find_by(user_id: current_user.id)
	 @instance1 = Instance.find_by(user_id: 20)

	end

	def new
		@instance = Instance.new
	end
	
	def show
		#@instance = Instance.new
		@drop = Instance.new
	

	end
	
	def create
		user_id = current_user.id
		client = DropletKit::Client.new(access_token: 'bfffb539a41beaa052846fa90735faabf80d33d406b51b074a7c02b2e64a96cc')
		@droplet = client.droplets.all()
		Array(@droplet).each do |f|
			@instance = Instance.create(user_id: user_id,name: f.name,instanceid: f.id,region: f.region.name,size: f.size,memory: f.memory,vcpus: f.vcpus,disk: f.disk,image: f.image.name)
			@ip = f.networks.v4
			
		end
		@instance = @droplet.name
	end

	def destroy
		@drop = Instance.new
		@drop = Instance.find_by(instanceid: 13158189)
		client = DropletKit::Client.new(access_token: 'bfffb539a41beaa052846fa90735faabf80d33d406b51b074a7c02b2e64a96cc')
		client.droplets.delete(id: @drop.instanceid)
	end

	
	private
	def instance_params
		params.require(:instance).permit(:name,:region)
	end
end

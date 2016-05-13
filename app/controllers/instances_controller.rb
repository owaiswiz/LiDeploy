class InstancesController < ApplicationController
	before_action :authenticate_user!,:except => [:hook]
	def index
		@instances = Instance.where(user_id: current_user.id)
		Array(@instances).each do |inst|
		 	client = DropletKit::Client.new(access_token: inst.api_key)
			begin
				instance = client.droplets.find(id: inst.instanceid)
				if instance.status == 'off'
					if inst.status == 'active'
						status = 'Powered Off'
					else
					status = inst.status
					end
				else
					status = instance.status
				end
					inst.update_attributes(:ip_address => instance.networks.v4[0].ip_address,:vcpus => instance.vcpus,:disk => instance.disk,:status => status)
			rescue
				if inst.status != 'Creating'
					inst.update_attributes(:status => "Not Found")
				end
			end
		end
	end

	def new
		@instance = Instance.new
	end

	def create
		@instance= Instance.new(instance_params)
		@instance.user_id = current_user.id
		@instance.status = 'Creating'
		if @instance.save
			redirect_to @instance.paypal_url(@instance)
		end
	end

	def destroy
	  @instance = Instance.find_by(user_id: current_user.id,id:params[:id])
		begin
			client = DropletKit::Client.new(access_token: @instance.api_key)
			client.droplets.delete(id: @instance.instanceid)
			flash[:notice] = "Instance Deleted Successfully"
		rescue
			flash[:error] = "Error Occured while Deleting. Please Try Again Later"
		end
		@instance.destroy
		redirect_to instances_path
	end
	def restart
		@instance = Instance.find_by(user_id: current_user.id,id: params[:id])
		#begin
			client = DropletKit::Client.new(access_token: @instance.api_key)
			client.droplet_actions.reboot(droplet_id: @instance.instanceid)
			@instance.update_attributes(:status => "Restarting")
			flash[:notice] = "Restarted Successfully"
		#rescue
			flash[:error] = "Error Occurred While Restarting. Try again after few minutes."
	#	end
		redirect_to instances_path
	end
	def shutdown
		@instance = Instance.find_by(user_id: current_user.id,id:params[:id])
		begin
			client = DropletKit::Client.new(access_token: @instance.api_key)
			client.droplet_actions.shutdown(droplet_id: @instance.instanceid)
			client.droplet_actions.power_off(droplet_id: @instance.instanceid)
			@instance.update_attributes(:status => "Powered Off")
			flash[:notice] = "Shutdown Initiated"
		rescue
			flash[:alert] = "Error Occurred While Shutting Down. Try again after few minutes."
		end
		redirect_to instances_path
	end
	def start
		@instance = Instance.find_by(user_id: current_user.id,id:params[:id])
		begin
			client = DropletKit::Client.new(access_token: @instance.api_key)
			@droplet = client.droplet_actions.power_on(droplet_id: @instance.instanceid)
			@instance.update_attributes(:status => "Starting")
			flash[:notice] = "Instance Started"
		rescue
			flash[:alert] = "Error Occurred while Starting Instance.Try again after few minutes."
		end
		redirect_to instances_path
	end
	def renew_put
			@instance = Instance.find_by(user_id:current_user,id: params[:id])
			render 'renew'
	end

	def renew_post
		begin
			@instance = Instance.find_by(user_id: current_user.id,id: params[:id])
			raise "Not Found" if @instance.nil?
			if @instance.update_attributes(:duration => params[:instance][:duration],:renew_status => "Renewing")
				redirect_to @instance.paypal_url(@instance)
			end
		rescue
			flash[:alert] = "Instance Not Found"
			redirect_to instances_path
		end

	end
	protect_from_forgery except: [:hook]
	  def hook
	    params.permit! # Permit all Paypal input params
	    status = params[:payment_status]
			@instance = Instance.find params[:custom]
	    if status == "Completed"
				if @instance.renew_status == "Renewing"
					@instance.update_attributes(:renew_status => "Renewed",:expires => @instance.expires+@instance.duration.months)
				elsif @instance.status != "new" || @instance.status != "active"
					@instance.update_attributes notification_params: params, transaction_id: params[:txn_id], purchased_at: Time.now
					current_do_key = ENV["DO_SECRET_KEY"]
					client = DropletKit::Client.new(access_token: current_do_key)
					droplet = DropletKit::Droplet.new(name: @instance.name,region: @instance.region,size: @instance.size,image: @instance.image)
					@created = client.droplets.create(droplet)
					@instance.update_attributes(:instanceid => @created.id,:status => @created.status,:api_key => current_do_key,:expires => Time.now+@instance.duration.months)
				else
					flash[:notice] = "Instance Already Created"
				end
			else
				@instance.update_attributes(:status=> "Payment Failed")
				flash[:notice] = "Payment Not Completed.Please Contact us at support@lideploy.com for further help"
			end
	    render nothing: true
	  end
	private
	def instance_params
		params.require(:instance).permit(:name,:distro,:region,:image,:size,:duration)
	end
end

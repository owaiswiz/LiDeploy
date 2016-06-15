class InstancesController < ApplicationController
	before_action :authenticate_user!,:except => [:hook]
	#Allocate a new Instance model
	def new
		@instance = Instance.new
	end

	#Create a new Instance from Form Input
	def create
		@instance= Instance.new(instance_params)
		@instance.user_id = current_user.id
		@instance.status = 'Waiting for Payment Confirmation'
		if @instance.save
			redirect_to @instance.paypal_url(@instance)
		end
	end

	#List all Instances of A Particular User
	def index
		@instances = Instance.where(user_id: current_user.id)
		begin
			Array(@instances).each do |inst|
			 	client = DropletKit::Client.new(access_token: inst.api_key)
				tries = 0
				begin
					instance = client.droplets.find(id: inst.instanceid)
					if instance.status == 'off'
						if inst.status == 'active' || inst.status == 'Not Found'
							status = 'Powered Off'
						elsif inst.status == 'Shutting Down'
							status = 'Powered Off'
							inst.update_attributes(:action => nil)
						else
							status = inst.status
						end
					elsif inst.status == 'Shutting Down' && (client.actions.find(id: inst.action).status == 'in-progress' || client.actions.find(id:inst.action).status == 'completed')
						status = inst.status
					else
						status = instance.status
					end
					inst.update_attributes(:ip_address => instance.networks.v4[0].ip_address,:vcpus => instance.vcpus,:disk => instance.disk,:status => status)
					if inst.temp_status == "Renewed"
						flash[:notice] = "Renewed Successfully"
						inst.update_attributes(:temp_status => nil)
					elsif inst.temp_status == "Resized"
						if inst.status == 'Resizing' && (client.actions.find(id: inst.action).status == "completed")
							client.droplet_actions.power_on(droplet_id: inst.instanceid)
							inst.update_attributes(:status => "Starting",:temp_status => nil,:action => nil)
							flash[:notice] = "Resized Successfully"
							flash[:notice1] = "Instance Started"
						end
					end
				rescue
					if inst.status == "Payment Failed"
						flash[:notice] = "Payment Not Completed for #{inst.name}.Please Contact us at support@lideploy.com for further help"
					elsif inst.status != 'Waiting for Payment Confirmation'
						tries += 1
						retry if tries < 2
						inst.update_attributes(:status => "Not Found",:ip_address => nil,:disk => nil)
					end
				end
			end
		rescue
			flash[:alert] = "An Unknown Error occurred.Please try again later."
		end
		if request.original_fullpath.match(/\/api\/get\/instances/)
			render 'instances/shared/_index',:layout => false
		end
	end
	#Start an Instance
	def start
		instance = Instance.find_by(user_id: current_user.id,id:params[:id])
		begin
			client = DropletKit::Client.new(access_token: instance.api_key)
			droplet = client.droplet_actions.power_on(droplet_id: instance.instanceid)
			instance.update_attributes(:status => "Starting")
			flash[:notice] = "Instance Started"
		rescue
			flash[:alert] = "Error Occurred while Starting Instance.Try again after few minutes."
		end
		redirect_to instances_path
	end

	#Delete an Instance
	def destroy
	  instance = Instance.find_by(user_id: current_user.id,id:params[:id])
		begin
			client = DropletKit::Client.new(access_token: instance.api_key)
			client.droplets.delete(id: instance.instanceid)
			flash[:notice] = "Instance Deleted Successfully"
		rescue
			flash[:alert] = "Instance Deleted Successfully"
		end
		instance.destroy
		redirect_to instances_path
	end

	#Restart an Instance
	def restart
		instance = Instance.find_by(user_id: current_user.id,id: params[:id])
		begin
			client = DropletKit::Client.new(access_token: instance.api_key)
			client.droplet_actions.reboot(droplet_id: instance.instanceid)
			instance.update_attributes(:status => "Restarting")
			flash[:notice] = "Restarted Successfully"
		rescue
			flash[:alert] = "Error Occurred While Restarting. Try again after few minutes."
		end
		redirect_to instances_path
	end

	#Power off an Instance
	def shutdown
		instance = Instance.find_by(user_id: current_user.id,id:params[:id])
		begin
			client = DropletKit::Client.new(access_token: instance.api_key)
			shuttingdown = client.droplet_actions.shutdown(droplet_id: instance.instanceid)
			instance.update_attributes(:status => "Shutting Down",:action => shuttingdown.id)
		#	client.droplet_actions.power_off(droplet_id: @instance.instanceid)
			flash[:notice] = "Shutdown Initiated.It will be completed within few seconds."
		rescue
			flash[:alert] = "Error Occurred While Shutting Down. Try again after few minutes."
		end
		redirect_to instances_path
	end

	#Renew Instance(Render Page part)
	def renew_put
			@instance = Instance.find_by(user_id:current_user,id: params[:id])
			render 'renew'
	end

	#Renew Instance(Process Payment and redirect to payment processor)
	def renew_post
		begin
			@instance = Instance.find_by(user_id: current_user.id,id: params[:id])
			raise "Not Found" if @instance.nil?
			if @instance.update_attributes(:duration => params[:instance][:duration],:temp_status => "Renewing")
				redirect_to @instance.paypal_url(@instance)
			end
		rescue
			flash[:alert] = "Instance Not Found"
			redirect_to instances_path
		end
	end

	#Resize an Instance
	def resize
		begin
			@instance = Instance.find_by(user_id: current_user.id,id:params[:id])
			raise "Not Found" if @instance.nil?
			if @instance.status != "Powered Off" && @instance.size != "2gb"
				shutdown
				flash[:notice1] = "Try resizing when instance is Powered Off"
			end
		rescue
			flash[:notice] = "Instance Not Found or Unknown State"
			redirect_to instances_path and return
		end
	end

	def resize_process
		@instance = Instance.find_by(user_id: current_user.id,id: params[:id])
		@instance.update_attributes(:temp_status => "Resizing",:duration => params[:instance][:duration])
		@instance.size=params[:instance][:size]
		redirect_to @instance.paypal_url(@instance)
	end

	protect_from_forgery except: [:hook]
	  def hook
	    params.permit! # Permit all Paypal input params
	    status = params[:payment_status]
			instance = Instance.find params[:item_number]
	    if status == "Completed"
				if instance.temp_status == "Renewing"
					instance.update_attributes(:temp_status => "Renewed",:expires => instance.expires+instance.duration.months)
				elsif instance.temp_status == "Resizing"
					client = DropletKit::Client.new(access_token: instance.api_key)
					resizing = client.droplet_actions.resize(droplet_id: instance.instanceid,size:params[:custom],disk: true)
					instance.update_attributes(:size => params[:custom],:status => "Resizing",:temp_status => "Resized",:expires => Time.now+instance.duration.months,:action => resizing.id)
				elsif instance.status == "Waiting for Payment Confirmation"
					instance.update_attributes notification_params: params, transaction_id: params[:txn_id], purchased_at: Time.now
					current_do_key = ENV["DO_SECRET_KEY"]
					client = DropletKit::Client.new(access_token: current_do_key)
					droplet = DropletKit::Droplet.new(name: instance.name,region: instance.region,size: instance.size,image: instance.image)
					created = client.droplets.create(droplet)
					instance.update_attributes(:instanceid => created.id,:status => created.status,:api_key => current_do_key,:expires => Time.now+instance.duration.months)
				else
					flash[:notice] = "Instance Already Created"
				end
			else
				instance.update_attributes(:status=> "Payment Failed")
			end
	    render nothing: true
	  end

	private
	def instance_params
		params.require(:instance).permit(:name,:distro,:region,:image,:size,:duration)
	end
end

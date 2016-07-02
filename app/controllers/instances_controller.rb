class InstancesController < ApplicationController
	before_action :authenticate_user!,:except => [:hook]
	#Allocate a new Instance model
	def new
		@newinstance = Instance.new
	end
	#Create a new Instance from Form Input
	def create
		createinstance= current_user.instances.new(instance_params)
		createinstance.status = 'Waiting for Payment Confirmation'
		if createinstance.save
			redirect_to createinstance.paypal_url(createinstance)
		end
	end
	#List all Instances of A Particular User
	def index
		@instances = current_user.instances
	end
	#Start an Instance
	def start
		instance = current_user.instances.find(params[:id])
		begin
			client = DropletKit::Client.new(access_token: instance.api_key)
			droplet = client.droplet_actions.power_on(droplet_id: instance.instanceid)
			instance.update_attributes(:status => "Starting")
			flash[:notice] = "Instance Started"
		rescue
			flash[:alert] = "Error Occurred while Starting Instance.Try again after few minutes."
		end
		instance = nil
		redirect_to instances_path
	end
	#Delete an Instance
	def destroy
	  instance = current_user.instances.find(params[:id])
		begin
			client = DropletKit::Client.new(access_token: instance.api_key)
			client.droplets.delete(id: instance.instanceid)
			flash[:notice] = "Instance Deleted Successfully"
		rescue
			flash[:alert] = "Instance Deleted Successfully"
		end
		instance.destroy
		instance = nil
		redirect_to instances_path
	end
	#Restart an Instance
	def restart
		instance = current_user.instances.find(params[:id])
		begin
			client = DropletKit::Client.new(access_token: instance.api_key)
			client.droplet_actions.reboot(droplet_id: instance.instanceid)
			instance.update_attributes(:status => "Restarting")
			flash[:notice] = "Restarted Successfully"
		rescue
			flash[:alert] = "Error Occurred While Restarting. Try again after few minutes."
		end
		instance = nil
		redirect_to instances_path
	end
	#Power off an Instance
	def shutdown
		instance = current_user.instances.find(params[:id])
		begin
			client = DropletKit::Client.new(access_token: instance.api_key)
			shuttingdown = client.droplet_actions.shutdown(droplet_id: instance.instanceid)
			instance.update_attributes(:status => "Shutting Down",:action => shuttingdown.id)
			flash[:notice] = "Shutdown Initiated.It will be completed within few seconds."
		rescue
			flash[:alert] = "Trying to shutdown.Try again in few minutes if Instance is still active."
		end
		instance = nil
		redirect_to instances_path
	end
	#Renew Instance(Render Page part)
	def renew_put
			@instance = current_user.instances.find(params[:id])
			render 'renew'
	end
	#Renew Instance(Process Payment and redirect to payment processor)
	def renew_post
		begin
			instance = current_user.instances.find(params[:id])
			raise "Not Found" if instance.nil?
			redirect_to instance.paypal_url(instance)	if instance.update_attributes(:duration => params[:instance][:duration],:temp_status => "Renewing")
		rescue
			flash[:alert] = "Instance Not Found"
			redirect_to instances_path
		end
	end
	#Resize an Instance
	def resize
		begin
			@instance = current_user.instances.find(params[:id])
			raise "Not Found" if @instance.nil?
			if @instance.status != "Powered Off" && @instance.size != "2gb"
				flash[:notice1] = "Try resizing when instance is Powered Off"
				shutdown
			end
		rescue
			flash[:notice] = "Instance Not Found or Unknown State"
			redirect_to instances_path and return
		end
	end
	#Resize - Process Resizing - Redirect to Paypal
	def resize_process
		instance = current_user.instances.find(params[:id])
		instance.update_attributes(:temp_status => "Resizing",:duration => params[:instance][:duration])
		instance.size=params[:instance][:size]
		redirect_to instance.paypal_url(instance)
	end
	#Update Instance status
	def update_instance
		inst = current_user.instances.find(params[:id])
		@vinst = inst
		begin
			tries = 0
			client = DropletKit::Client.new(access_token: inst.api_key)
			if !inst.action.nil?
				actionstatus = client.actions.find(id:inst.action).status
			end
			begin
				instance = client.droplets.find(id: inst.instanceid)
				if instance.status == 'off'
					if inst.status == 'active' || inst.status == 'Not Found'
						status = 'Powered Off'
					elsif inst.status == 'Shutting Down'
						status = 'Powered Off'
						inst.update_attributes(action: nil)
					else
						status = inst.status
					end
				elsif inst.status == 'Shutting Down' && (actionstatus == 'in-progress' || actionstatus == 'completed')
					status = inst.status
				else
					status = instance.status
				end
				inst.update_attributes(ip_address: instance.networks.v4[0].ip_address,vcpus: instance.vcpus,disk: instance.disk,status: status)
				if inst.temp_status == "Renewed"
					flash.now[:notice] = "Renewed Successfully"
					inst.update_attributes(temp_status: nil)
				elsif inst.temp_status == "Resized"
					if inst.status == 'Resizing' && (actionstatus == "completed")
						client.droplet_actions.power_on(droplet_id: inst.instanceid)
						inst.update_attributes(status: "Starting",temp_status: nil,action: nil)
						flash.now[:notice] = "Resized Successfully"
						flash.now[:notice1] = "Instance Started"
					end
				end
			rescue => e
				if inst.status == "Payment Failed"
					flash.now[:notice] = "Payment Not Completed for #{inst.name}.Please Contact us at support@lideploy.com for further help"
					inst.update_attributes(status: "Payment failed");
				elsif inst.status != 'Waiting for Payment Confirmation' && inst.status != "Payment failed"
					tries += 1
					retry if tries < 2
					inst.update_attributes(status: "Not Found",ip_address: nil,disk: nil)
				end
			end
		rescue => e
			flash.now[:alert] = "An Unknown Error occurred.Please try again later."
		end
		render "instances/shared/update_instance",layout: false
	end

	protect_from_forgery except: [:hook]
	  def hook
	    params.permit! # Permit all Paypal input params
			instance = Instance.find(params[:item_number])
	    if params[:payment_status] == "Completed" && (params[:payment_gross].to_f == instance.price)
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
				end
			else
				instance.update_attributes(:status=> "Payment Failed")
			end
			instance = nil
	    render nothing: true
	  end

	private
	def instance_params
		params.require(:instance).permit(:name,:distro,:region,:image,:size,:duration)
	end
end

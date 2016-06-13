class RecordsController < ApplicationController
  def index
    @domains = current_user.domains
    @newdomain = Domain.new
    @instances = current_user.instances
  end
  def create
    newdomain = current_user.domains.new(domain_params)
    # begin
      newdomain.api_key = ENV["DO_SECRET_KEY"]
      client = DropletKit::Client.new(access_token: newdomain.api_key)
      domain = DropletKit::Domain.new(name: newdomain.name, ip_address: newdomain.ip_address)
      client.domains.create(domain)
    # rescue
      # redirect_to domains_path and return
      # flash[:alert] = "Failed to create Domain Record. Please recheck domain name and try again later."
    # end
    if newdomain.save
      flash[:notice] = "Domain Record Created."
      redirect_to domains_path
    else
      flash[:notice] = "Domain Record not created."
    end
  end

  def view_domain
    @domain = current_user.domains.find_by(:name => params[:name])
    @records = @domain.records
    @newrecord = @domain.records.new
    render 'records/domain'
  end

  def delete_domain
    domain = current_user.domains.find_by(:name => params[:name])
    begin
      client = DropletKit::Client.new(access_token:domain.api_key)
      client.domains.delete(name:domain.name)
      flash[:notice] = "Domain #{domain.name} deleted successfully."
    rescue
      flash[:alert] = "Domain Deleted"
    end
    domain.destroy
    redirect_to domains_path
  end

  def add_record
    domain = current_user.domains.find_by_name(params[:name])
    client = DropletKit::Client.new(access_token:domain.api_key)
    newrecord = DropletKit::DomainRecord.new(type: params[:record][:type], name: params[:record][:name], data: params[:record][:data],port: params[:record][:port],weight: params[:record][:weight],priority: params[:record][:priority])
    createdrecord = client.domain_records.create(newrecord, for_domain: params[:name])
    puts createdrecord.id
    puts params
    redirect_to view_domain_path
  end
  private
  def domain_params
    params.require(:domain).permit(:name,:ip_address)
  end
  #def record_params
  #  params.require(:record).permit(:name,:data,:priority,:port,:weight)
  #end
end

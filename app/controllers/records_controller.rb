class RecordsController < ApplicationController
  def index
    @domains = current_user.domains
    @newdomain = Domain.new
    @instances = current_user.instances
  end
  def create
    newdomain = current_user.domains.new(domain_params)
    begin
      newdomain.api_key = ENV["DO_SECRET_KEY"]
      client = DropletKit::Client.new(access_token: newdomain.api_key)
      domain = DropletKit::Domain.new(name: newdomain.name, ip_address: newdomain.ip_address)
      client.domains.create(domain)
    rescue
      flash[:alert] = "Failed to create Domain Record. Please recheck domain name and try again later."
      redirect_to domains_path and return
    end
    if newdomain.save
      flash[:notice] = "Domain Record Created."
      redirect_to domains_path
    else
      flash[:notice] = "Domain Record not created."
    end
  end

  def view_domain
    @domain = Domain.find_by_name(params[:name])
    @records = @domain.records
    @newrecod = @domain.records.new
    render 'records/domain'
  end

  def delete_domain
    domain = current_user.domains.find_by(:name => params[:name])
  #  begin
      client = DropletKit::Client.new(access_token:domain.api_key)
      client.domains.delete(name:domain.name)
      flash[:notice] = "Domain #{domain.name} deleted successfully."
  #  rescue
  #    flash[:alert] = "Domain Deleted"
  #  end
    domain.destroy
    redirect_to domains_path
  end
  private
  def domain_params
    params.require(:domain).permit(:name,:ip_address)
  end
end

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
      if newdomain.save
        flash[:notice] = "Domain Record Created."
      else
        flash[:notice] = "Domain Record not created."
      end
    rescue => e
      exception_message = $1.humanize if e.message.match(/"message":"(.*)"/)
      flash[:alert] = "Failed to create Domain Record. #{exception_message}"
    end
    redirect_to domains_path
  end

  def view_domain
    @domain = current_user.domains.find_by(:name => params[:domainname])
    @records = @domain.records
    @newrecord = @domain.records.new
    render 'records/domain'
  end

  def delete_domain
    domain = current_user.domains.find_by(:name => params[:domainname])
    begin
      tries = 0
      client = DropletKit::Client.new(access_token:domain.api_key)
      client.domains.delete(name:domain.name)
      flash[:notice] = "Domain #{domain.name} deleted successfully."
    rescue
      tries += 1
      retry if tries < 1
      flash[:alert] = "Domain Deleted"
    end
    domain.destroy
    redirect_to domains_path
  end

  def add_record
    domain = current_user.domains.find_by_name(params[:domainname])
    record = domain.records.create(record_params)
    begin
      client = DropletKit::Client.new(access_token:domain.api_key)
      newrecord = DropletKit::DomainRecord.new(type: params[:record][:type], name: params[:record][:name], data: params[:record][:data],port: params[:record][:port],weight: params[:record][:weight],priority: params[:record][:priority])
      createdrecord = client.domain_records.create(newrecord, for_domain: params[:domainname])
      record.record_id = createdrecord.id
      if record.save
        redirect_to view_domain_path and return
      else
        flash[:alert] = "Error Occured while saving record"
      end
    rescue
      flash[:alert] = "Failed"
    end
    redirect_to view_domain_path
  end
  def update_record
    record = current_user.domains.find_by_name(params[:domainname]).records.find_by(params[:record][:id])
    updaterecord = DropletKit::DomainRecord.new(type: params[:record][:type], name: params[:record][:name], data: params[:record][:data],port: params[:record][:port],weight: params[:record][:weight],priority: params[:record][:priority])
    client.domain_records.update(updaterecord, for_domain: params[:domainname], id: record.id)
    record.update_attributes(record_params)
    redirect_to view_domain_path
  end
  private
  def domain_params
    params.require(:domain).permit(:name,:ip_address)
  end
  def record_params
   params.require(:record).permit(:type,:name,:data,:priority,:port,:weight)
  end
end

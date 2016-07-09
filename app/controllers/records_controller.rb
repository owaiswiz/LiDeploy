class RecordsController < ApplicationController
  def index
    @domains = current_user.domains.recent
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
      default_record = (client.domain_records.all(for_domain: newdomain.name).to_a)[-1]
      newdomain.save
      newdomain.records.create(record_type:'A',name:'@',data: newdomain.ip_address,record_id: default_record.id)
      flash[:notice] = "Domain Record Created."
    rescue => e
      if e.message.match(/"message":"(.*)"/)
        if $1.match(/Name Only valid hostname/)
          exception_message = "Only valid hostname characters are allowed. (a-z, a-z, 0-9, ., and -) or a single record of '@'."
        else
          exception_message = $1
        end
      end
      flash[:alert] = "Failed to create Domain Record. #{exception_message}"
    end
    newdomain,default_record,domain,exception_message = nil
    redirect_to domains_path
  end

  def view_domain
    @domain = current_user.domains.find_by_name(params[:domainname])
    @records = @domain.records.alphabetically
    @newrecord = @domain.records.new
    render 'records/domain'
  end

  def delete_domain
    domain = current_user.domains.find_by_name(params[:domainname])
    tries = 0
    begin
      client = DropletKit::Client.new(access_token:domain.api_key)
      client.domains.delete(name:domain.name)
      flash[:notice] = "Domain #{domain.name} deleted successfully."
    rescue
      tries += 1
      retry if tries < 2
      flash[:alert] = "Domain Deleted"
    end
    domain.destroy
    domain = nil
    redirect_to domains_path
  end

  def add_record
    domain = current_user.domains.find_by_name(params[:domainname])
    begin
      client = DropletKit::Client.new(access_token:domain.api_key)
      newrecord = DropletKit::DomainRecord.new(type: params[:record][:record_type], name: params[:record][:name], data: params[:record][:data],port: params[:record][:port],weight: params[:record][:weight],priority: params[:record][:priority])
      crecord = client.domain_records.create(newrecord, for_domain: params[:domainname])
      if !crecord.id.nil?
        record = domain.records.create(record_type: crecord.type,name: crecord.name,data: crecord.data,port:crecord.port,weight:crecord.weight,priority: crecord.priority,record_id: crecord.id)
        flash[:notice] = "Record Created Successfully"
      else
        flash[:alert] = "Error Occured while saving record"
      end
    rescue => e
      if e.message.match(/"message":"(.*)"/)
        err = $1
        if err.match(/Name Only valid hostname/)
          exception_message = "Only valid hostname characters are allowed. (a-z, a-z, 0-9, ., and -) or a single record of '@'."
        else
          exception_message = err
        end
      end
      flash[:alert] = "Error Occurred while creating Domain Record. #{exception_message}"
    end
    record,crecord,err,exception_message,client = nil
    redirect_to view_domain_path
  end
  def update_record
    begin
      domain = current_user.domains.find_by_name(params[:domainname])
      record = domain.records.find(params[:record][:id])
      client = DropletKit::Client.new(access_token:domain.api_key)
      updaterecord = DropletKit::DomainRecord.new(type: params[:record][:record_type], name: params[:record][:name], data: params[:record][:data],port: params[:record][:port],weight: params[:record][:weight],priority: params[:record][:priority])
      crecord = client.domain_records.update(updaterecord, for_domain: params[:domainname], id: record.record_id)
      record.update_attributes(name: crecord.name,data: crecord.data,port:crecord.port,weight:crecord.weight,priority: crecord.priority)
      flash[:notice] = "Record Updated"
    rescue => e
      if e.message.match(/"message":"(.*)"/)
        if $1.match(/Name Only valid hostname/)
          exception_message = "Only valid hostname characters are allowed. (a-z, a-z, 0-9, ., and -) or a single record of '@'."
        else
          exception_message = $1
        end
      end
      flash[:alert] = "Error occured while updating record. #{exception_message}"
    end
    record,client,updaterecord,crecord,exception_message = nil
    redirect_to view_domain_path
  end

  def delete_record
    begin
      domain = current_user.domains.find_by_name(params[:domainname])
      record = domain.records.find(params[:id])
      client = DropletKit::Client.new(access_token:domain.api_key)
      client.domain_records.delete(for_domain: domain.name, id: record.record_id)
      flash[:notice] = "Record Deleted"
    rescue
      flash[:alert] = "Record Deleted"
    end
    record.destroy
    record,client = nil
    redirect_to view_domain_path
  end
  private
  def domain_params
    params.require(:domain).permit(:name,:ip_address)
  end
  def record_params
   params.require(:record).permit(:record_type,:name,:data,:priority,:port,:weight)
  end
end

class PagesController < ApplicationController
  def legal
    render "pages/#{params[:page]}/#{params[:name]}"
  end
  def pricing
    render "pages/pricing"
  end
  def features
    render "pages/features"
  end

end

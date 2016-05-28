class PagesController < ApplicationController
  def subpage
    render "pages/#{params[:page]}/#{params[:name]}"
  end
  def page
    render "pages/#{params[:name]}"
  end
  def help
    render "pages/help/help"
  end
end

class BriefsController < ApplicationController
  before_filter :authenticate
  before_filter :authorized_user, :only => :destroy
  def create
    @brief = current_user.briefs.build(params[:brief])
    @brief.save
    if @brief.save
      redirect_to root_path, :flash => { :success => "New Resident Brief created."}
    else
      @feed_items = []
      render 'pages/home'
    end
  end
  def destroy
    @brief.destroy
    redirect_to root_path, :flash => { :success => "Brief was deleted."}
  end

  private
  
  def authorized_user
    @brief = Brief.find(params[:id]) or admin.user
    redirect_to root_path unless current_user?(@brief.user || admin.user)
  end
end

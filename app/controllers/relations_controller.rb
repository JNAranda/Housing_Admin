class RelationsController < ApplicationController
  before_filter :authenticate

  def create
    @user = User.find(params[:relation][:stalked_id])
    current_user.stalk!(@user)
    respond_to do |format|
      format.html { redirect_to @user}
      format.js
    end
  end

  def destroy
    @user = Relation.find(params[:id]).stalked
    current_user.unstalk!(@user)
    respond_to do |format|
      format.html { redirect_to @user}
      format.js
    end
  end
end
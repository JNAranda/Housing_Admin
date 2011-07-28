class UsersController < ApplicationController
  before_filter :authenticate, :except => [:show, :new, :create]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user, :only => :destroy
  
  def index
    @title = "All Interns"
    @users = User.paginate(:page => params[:page])
  end
  def new
    @title = "Sign Up"
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    @title = @user.name
    @briefs = @user.briefs.paginate(:page => params[:page])
  end
  
  def create
      @user = User.new(params[:user])
      if @user.save
        sign_in @user
        flash[:success] = "Welcome to InternAdmin"
        redirect_to @user
      else
        @title = "Sign up"
        render 'new'
      end
  end
 def edit
    @user = User.find(params[:id])
    @title = "Edit Intern"
  end
  
 def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Intern Updated."
      redirect_to @user
    else
      @title = "Edit Intern"
      render 'edit'
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    redirect_to users_path, :flash => { :success => "Intern Deleted"}
  end
  def stalking
    @title = "Stalking"
    @user = User.find(params[:id])
    @users = @user.stalking.paginate(:page => params[:page])
    render 'show_follow'
  end
  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(:page => params[:page])
    render 'show_follow'
  end
  private
    def authenticate
      deny_access unless signed_in?
    end  
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
    def admin_user
      user = User.find(params[:id])
      redirect_to(root_path) if !current_user.admin? || current_user?(user)
      
    end
end



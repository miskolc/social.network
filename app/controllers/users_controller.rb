class UsersController < ApplicationController
  before_filter :authenticate_user!, 
                only: [:destroy , :following, :followers]
  before_filter :admin_user, only: :destroy
  def index
    @users = User.paginate(page: params[:page])
  end    

  def show
    @user=User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed"
    redirect_to users_path
  end 

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end
    
  def followers 
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end  

  private
    def admin_user
      redirect_to root_path unless current_user.is_admin?
    end  
end

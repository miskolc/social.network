class MicropostsController < ApplicationController
    before_filter :authenticate_user!

    def create 
        @micropost = current_user.microposts.build(params[:micropost])
        if @micropost.save
            flash[:success] = "Status updated!"
            redirect_to root_path
        else    
            @feed_items = []
            render 'static_pages/home'
        end    
    end
    
    def destroy

    end  
end    
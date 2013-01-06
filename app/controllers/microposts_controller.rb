class MicropostsController < ApplicationController
    before_filter :authenticate_user!
    before_filter :correct_user, only: [:edit, :update, :destroy]

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
    
    def edit
        respond_to do |format|
            format.js
        end 
    end  

    def update
        if @micropost.update_attributes(params[:micropost])
            respond_to do |format|
                format.html { redirect_to root_path }
                format.js
            end
        else
            @feed_items = []
            render 'static_pages/home'
        end        
    end  

    def destroy
        @micropost.destroy
        respond_to do |format|
            format.js
        end
    end

    private

        def correct_user
            @micropost = current_user.microposts.find_by_id(params[:id])
            redirect_to root_path if @micropost.nil?
        end  
end    
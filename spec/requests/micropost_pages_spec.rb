require 'spec_helper'
include Warden::Test::Helpers
Warden.test_mode!

describe "Micropost pages" do
    subject { page }

    let(:user) { FactoryGirl.create(:user) }

    before { login_as(user, scope: :user) }

    describe "micropost creation" do

        before{ visit root_path }

        describe "with invalid information" do

            it "should not create a micropost" do
                expect{ click_button "Update Status" }.not_to change(User, :count)
            end

            describe "error message" do
                before { click_button "Update Status" }
                it { should have_content('error') }
            end    
        end    
    end

    describe "micropost destruction" do
        before{ FactoryGirl.create(:micropost, user: user) }
        
        describe "as correct user" do
            before{ visit root_path }

            it "should destroy micropost" do
                expect { click_link "delete" }.should change(Micropost,:count).by(-1)
            end   
        end

    end    
end


require 'spec_helper'
include Warden::Test::Helpers
Warden.test_mode!

describe "Authentication" do

    subject { page }

    describe "signin page" do
        before { visit new_user_session_path }

        it {should have_selector('h1', text: "Sign in")}
        it {should have_selector('title', text: "Sign in")}
    end

    describe "signin" do

        before {visit new_user_session_path}

        describe "with invalid information" do
            before {click_button "Sign in"}

            it {should have_selector('title', text: "Sign in")}
            it {should have_selector('div.alert.alert-error', text: "Invalid")}

            describe "after visiting another page" do
                before {click_link "Home"}

                it {should_not have_selector('div.alert.alert-error')}
            end    
        end  

        describe "with valid information" do
            let(:user) {FactoryGirl.create(:user)}

            before do
              login_as( user, scope: :user) 
              visit root_path
            end  

            it {should have_selector('h1', text: user.name)}
            it {should have_link('Profile',     href: user_path(user))}
            it {should have_link('Sign out',    href: destroy_user_session_path)}
            it {should have_link('Settings',    href: edit_user_registration_path)}
            it {should have_link('Users',       href: users_path)}
            it {should_not have_link('Sign in', href: new_user_registration_path)}

            describe "followed by signout" do
                before { click_link "Sign out" }
                it { should have_link('Sign in') }
            end    
        end  
    end 

    describe "authorization" do

        describe "for non-signed-in users" do
            let(:user) { FactoryGirl.create(:user) }

            describe "when attempting to visit a protected page" do
                before do
                    visit edit_user_registration_path
                    fill_in "Email",    with: user.email
                    fill_in "Password", with: user.password
                    click_button "Sign in"
                end   

                describe "after signing in" do
                    it "should render the desired protected page" do
                        page.should have_selector('title', text: "Edit user")
                    end

                    describe "when signing in again" do
                        before do
                            click_link "Sign out"
                            click_link "Sign in"
                            fill_in "Email",    with: user.email
                            fill_in "Password", with: user.password
                            click_button "Sign in"
                        end  

                        it "should render the default (profile) page" do
                            page.should have_selector('h1', text: user.name)
                        end  
                    end    
                end     
            end

            describe "in the Users controller" do

                describe "visiting the edit page" do
                    before { visit edit_user_registration_path }
                    it { should have_selector('title', text:"Sign in") }
                    it { should have_selector('div.alert.alert-error') }
                end

                describe "visiting the following page" do
                    before { visit following_user_path(user) }
                    it { should have_selector('title', text: 'Sign in') }
                end    

                describe "visiting the followers page" do
                    before { visit followers_user_path(user) }
                    it { should have_selector('title', text: 'Sign in') }
                end    

                describe "visiting the user profile page" do
                    before { visit user_path(user) }
                    it { should_not have_selector('input', value: 'Unfollow')}
                    it { should_not have_selector('input', value: 'Follow')}
                end    
            end
        end 

        describe "In the Microposts controller" do
            describe "submitting to the create action" do
                before { post microposts_path }
                specify { response.should redirect_to(new_user_session_path) }
            end

            describe "submitting to the destroy action" do
                before { delete micropost_path(FactoryGirl.create(:micropost)) }
                specify { response.should redirect_to(new_user_session_path) }
            end    
        end    

        describe "In the Relationships controller" do
            describe "submitting to the create action" do
                before { post relationships_path }
                specify { response.should redirect_to(new_user_session_path) }
            end

            describe "submitting to the destroy action" do
                before { delete relationship_path(1) }
                specify { response.should redirect_to(new_user_session_path) }
            end   
        end    

        describe "as non-admin user" do
            let(:user) { FactoryGirl.create(:user) }
            let(:non_admin) { FactoryGirl.create(:user) }

            before{ login_as(non_admin, scope: :user)}

            describe "submitting a DELETE request to the Users#destroy  action" do
                before{ delete user_path(user) }
                specify{ response.should redirect_to(root_path) }
            end    
        end       
    end   
end

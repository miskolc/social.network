require 'spec_helper'
include Warden::Test::Helpers
Warden.test_mode!


describe "UserPages" do
  
    subject {page}
    
    describe "index" do

        let(:user) { FactoryGirl.create(:user) }

        before(:all) { 60.times {FactoryGirl.create(:user) }}
        after(:all)  { User.delete_all} 
        
        before(:each) do 
            visit users_path(page: 2)
        end

        it { should have_selector('title', text: "All users") } 
        it { should have_selector('h1',    text: "All users") }

        describe "pagination" do

            it { should have_selector('div.pagination') }   

            it "should list each user" do
                User.paginate(page: 2).each do |user|
                    page.should have_selector("li>a", text: user.name)

                end
            end

        end

        describe "delete links" do
            it {should_not have_link("delete")} 
            describe "as an admin user" do
                let(:admin) {FactoryGirl.create(:admin)}
                before do
                    login_as(admin, scope: :user)
                    visit users_path
                end 
                it {should have_link("delete", href: user_path(User.first))}
                it "should be able to delete another user" do
                    expect { click_link("delete") }.to change(User, :count).by(-1)
                end 
                it {should_not have_link("delete", href: user_path(admin))}
            end 
        end 
        
    end 

    describe "signup page" do
        before{ visit new_user_registration_path }

        it {should have_selector('h1', text: 'Sign up') }
        it {should have_selector('title', text: full_title('Sign up'))}
    end  

    describe "profile page" do
        let(:user) {FactoryGirl.create(:user)}

        before{ visit user_path(user)}

        it {should have_selector('h1', text: user.name) }
        it {should have_selector('title', text: user.name) }
    end 

    describe "signup" do
        before {visit new_user_registration_path }

        let(:submit) { "Sign up"}

        describe "with invalid information" do
            it "should not create a user" do
                expect { click_button submit}.not_to change(User, :count)
            end 

            describe "after submission" do
                before { click_button submit}

                it {should have_selector('h1', text: "Sign up")}
                it {should have_selector('h1', text: "Sign up")}
                it {should have_content('error')}
                it {should_not have_content('Password digest')}
            end 
        end 

        describe "with valid information" do

            before do
                fill_in  "Name",         with: "Example User"
                fill_in  "Email",        with: "user@example.com"
                fill_in  "Password",     with: "foobar"
                fill_in  "Password confirmation", with:"foobar"
            end 

            it "should create a user" do
                expect { click_button submit}.to change(User,:count).by(1)
            end 

            describe "after saving a user" do
                before{ click_button submit}

                let(:user) {User.find_by_email("user@example.com")}

                it {should have_selector('title', text: user.name)}

                it {should have_selector('div.alert.alert-success', text:"Welcome")}
            
                it {should have_link('Sign out')}
            end 
        end 
    end 

    describe "edit" do

        let(:user) { FactoryGirl.create(:user) }
        before do
            login_as(user, scope: :user)
            visit edit_user_registration_path(user) 
        end 


        describe "page" do 

            it { should have_selector('h1',    text: "Update your profile") }
            it { should have_selector('title', text: "Edit user")}
            it { should have_link('change', href: 'http://gravatar.com/emails')}
        end 

        describe "with invalid information" do
            before {click_button "Update"}

            it { should have_content('error') }
        end 

        describe "with valid information" do
            let(:new_name) { "New Name"}
            let(:new_email) { "new@example.com"}
            let(:new_password) {"barbaz"}
            before do
                fill_in "Name",             with: new_name
                fill_in "Email",            with: new_email 
                fill_in "Password",         with: new_password
                fill_in "Password confirmation", with: new_password
                fill_in "Current password", with: user.password
                click_button "Update"
            end 

            it {should have_selector('title', text: new_name)}
            it {should have_link('Sign out', href: destroy_user_session_path)}
            it {should have_selector('div.alert.alert-notice')}
            specify {user.reload.name.should  == new_name}
            specify {user.reload.email.should == new_email}
        end 

    end 
end

require 'spec_helper'

describe User do
    before do 
        @user = User.new( name: "Example User", email: "user@example.com",
                        password: "foobar", password_confirmation:"foobar")
    end 

    subject { @user }

    it {should respond_to(:name)}
    it {should respond_to(:email)}
    it {should respond_to(:password)}
    it {should respond_to(:password_confirmation)}
    it {should respond_to(:is_admin)}
    it {should respond_to(:microposts)}
    it {should respond_to(:feed)}
    it {should respond_to(:relationships)}
    it {should respond_to(:followed_users)}
    it {should respond_to(:reverse_relationships)}
    it {should respond_to(:followers)}
    it {should respond_to(:following?)}
    it {should respond_to(:follow!)}
    it {should respond_to(:unfollow!)}

    it {should be_valid}
    specify { @user.is_admin?.should_not be_true }

    describe "accessible attributes" do
        it "should not allow access to admin" do
            expect do 
                User.new(is_admin: "1")
            end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)    
        end    
    end    

    describe "when name is not present" do
        before { @user.name=" " }
        it {should_not be_valid}
    end 

    describe "when email is not present" do
        before {@user.email= " "}
        it {should_not be_valid}
    end 

    describe "when name is too long" do
        before {@user.name="a"*51}
        it {should_not be_valid}
    end

    describe "when email address is allready taken" do
        before do 
            user_with_same_email=@user.dup
            user_with_same_email.email=@user.email.upcase
            user_with_same_email.save
        end 

        it {should_not be_valid}
    end 

    describe "when password is not present" do
        before {@user.password = @user.password_confirmation = " "}
        it { should_not be_valid}

    end 

    describe "when password doesn't match cofirmation" do
        before {@user.password_confirmation = "mismatch"}
        it { should_not be_valid}
    end 


    describe "when password is too short" do
        before {@user.password= @user.password_confirmation="a" * 5}
        it {should_not be_valid}
    end 

    describe "micropost associations" do

        before { @user.save }
        let!(:older_micropost) do
            FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago) 
        end    
        let!(:newer_micropost) do 
            FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago) 
        end    

        it "should have the right microposts in the right order" do
            @user.microposts.should == [ newer_micropost, older_micropost]
        end 

        it "should destroy associated microposts" do
            #duplicate @user.microposts
            microposts = @user.microposts.dup
            @user.destroy
            microposts.each do |micropost|
                Micropost.find_by_id(micropost.id).should be_nil
            end    
        end  

        describe "status" do
            let(:unfollowed_post) do
                FactoryGirl.create(:micropost, user: FactoryGirl.create(:user), content: "foo")
            end
            let(:followed_user) { FactoryGirl.create(:user) }

            before do
                @user.follow!(followed_user)
                3.times { followed_user.microposts.create!(content: "Lorem ipsum") }
            end    

            its(:feed) { should include(older_micropost) }
            its(:feed) { should include(newer_micropost) }
            its(:feed) { should_not include(unfollowed_post) }
            its(:feed) do
                followed_user.microposts.each do |micropost|
                    should include(micropost)
                end    
            end    

        end 
    end 

    describe "following" do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
            @user.save
            @user.follow!(other_user)
        end    
        it { should be_following(other_user) }
        its(:followed_users) { should include(other_user) }

        describe "followed user" do
            subject { other_user }
            its(:followers) { should include(@user) }
        end 

        describe "and unfollowing" do
            before { @user.unfollow!(other_user) }

            it { should_not be_following(other_user) }
            its(:followed_users) {should_not include(other_user) }
        end    
    end   

end

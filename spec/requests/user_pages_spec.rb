require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "index" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) do
      sign_in user
      visit users_path
    end

    describe "page" do
      it { should have_content('All users') }
      it { should have_title('All users') }
    end
    
    describe "pagination" do
      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all)  { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end
    
    describe "delete links" do

      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end
  end
  
  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "Foo") }
    let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "Bar") }    
    before { visit user_path(user) }
  
    it { should have_content(user.name) }
    it { should have_title(user.name) }
    
    describe "microposts" do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }
    end
    
  end
  
  
  describe "signup" do
    before { visit signup_path }

    describe "page" do
      it { should have_content('Sign up') }
      it { should have_title('Sign up') }
    end

    describe "with invalid information" do
      
      it "should not create a user" do
        expect { invalid_sign_up }.not_to change(User, :count)
      end
      
      describe "after submission" do
        before { invalid_sign_up }
        it { should have_title('Sign up') }
        it { should have_content('error') }
      end
      
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.build(:user) }

      it "should create a user" do
        expect { sign_up user }.to change(User, :count).by(1)
      end
      
      describe "after saving the user" do
        before { sign_up user }
        let(:found_user) { User.find_by(email: user.email) }
        it { should have_link('Sign out') }
        it { should have_title(found_user.name) }
        it { should have_success_message('Welcome') }
      end
      
    end
    
  end
 
  
  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user 
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_content("Update your profile") }
      it { should have_title("Edit user") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }
      it { should have_content('error') }
    end
    
    describe "with valid information" do
      let(:new) { {name: 'New Name', email: 'new@example.com'} }
      before { edit_profile(new,user) }

      it { should have_title(new[:name]) }
      it { should have_success_message('Profile updated') }
      # it { should have_link('Sign out') }
      specify { expect(user.reload.name).to  eq new[:name] }
      specify { expect(user.reload.email).to eq new[:email] }
    end
    
    describe "forbidden attributes" do
      let(:params) do
        { user: { admin: true, password: user.password,
                  password_confirmation: user.password } }
      end
      before do
        sign_in user, no_capybara: true
        patch user_path(user), params
      end
      specify { expect(user.reload).not_to be_admin }
    end
    
  end
  
end

require 'spec_helper'

describe "LayoutLinks" do
  it "should have a homepage at '/'" do
    get '/'
    response.should have_selector('title', :content => "Home")
  end  
  it "should have a contact page at '/contact'" do
    get '/contact'
    response.should have_selector('title', :content => "Contact")
  end
  it "should have an about page at '/about'" do
    get '/about'
    response.should have_selector('title', :content => "About")
  end
  it "should have an help page at '/help'" do
    get '/help'
    response.should have_selector('title', :content => "Help")
  end
  it "should have an signup page page at '/signup'" do
    get '/signup'
    response.should have_selector('title', :content => "Sign Up")
  end
  it "should have an signin page page at '/signin'" do
     get '/signin'
     response.should have_selector('title', :content => "Sign In")
   end
  it "should have the right links on the layout" do
  visit root_path
  response.should have_selector('title', :content => "Home")
  click_link "About"
  response.should have_selector('title', :content => "About")
  end
  describe "before sign in" do
    it "should have sign in link" do
      visit root_path
      response.should have_selector("a", :href => signin_path, :content => "Sign In")
    end
  end
  describe "when signed in" do
    before(:each) do
      @user = Factory(:user)
      visit signin_path
      fill_in :email, :with => @user.email
      fill_in :password, :with => @user.password
      click_button
    end
    it "should have a signout link" do
      visit root_path
      response.should have_selector("a", :href => signout_path, :content => "Sign Out")
    end
    
    it "should have a profile link" do
      visit root_path
      response.should have_selector("a", :href => user_path(@user), :content => "My Residents")
    end
   it "should have a Interns link" do
      visit root_path
      response.should have_selector("a", :href => users_path, :content => "All Interns")
    end
  end
end
  
  


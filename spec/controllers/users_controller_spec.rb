require 'spec_helper'

describe UsersController do
  render_views
  describe "GET 'index'" do
    describe "for non-signed in" do
      it "should not allow access" do
        get :index
        response.should redirect_to(signin_path)
      end
    end
    describe "for signed in" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        Factory(:user, :email => "this@example.com")
        Factory(:user, :email => "this@example.edu")
      end
      it "should be success" do
        get :index
        response.should be_success
      end      
      it "should have the right title" do
        get :index
        response.should have_selector('title', :content => "All Interns")
      end
      it "should have an element for each user" do
        get :index
        User.all.each do |user|
          response.should have_selector('li', :content => user.name, :content => user.email)
      end
     end
     
      it "should have delete for admins" do
        @user.toggle!(:admin)
        other_user = User.all.second
        get :index
        response.should have_selector('a', :href => user_path(other_user),
                                      :content => 'delete')
      end
      it "shouldn't have delete for interns" do
        other_user = User.all.second
        get :index
        response.should_not have_selector('a', :href => user_path(other_user),
                                               :content => 'delete')
      end
    end  
  end
  
  describe "GET 'show'" do
    before(:each) do
      @user = Factory(:user)
    end
    
    it "should be successful" do
      get :show, :id => @user.id
      response.should be_success
    end
    
    it "should find the right user" do
      get :show, :id => @user.id
      assigns(:user).should == @user
    end
    
    it "should have the right title" do
        get :show, :id => @user.id
        response.should have_selector('title', :content => @user.name)
    end
    
    it "should have the right user's name" do
      get :show, :id => @user.id
      response.should have_selector('h1', :content => @user.name)
    end
    it "should have the right URL" do
      get :show, :id => @user
      response.should have_selector('td>a', :content => user_path(@user), :href => user_path(@user))
    end
    it "should show user's briefs " do
      b1 = Factory(:brief, :user => @user, :content => "asdfasdf")
      b2 = Factory(:brief, :user => @user, :content => "asdfasdfff")
      get :show, :id => @user
      response.should have_selector('span.content', :content => b1.content)
      response.should have_selector('span.content', :content => b2.content)
    end
    it "should paginate briefs" do
      31.times { Factory(:brief, :user => @user, :content => "asfasfasfd")}
      get :show, :id => @user
      response.should have_selector('div.pagination')
    end
    it "should show count" do
      10.times{ Factory(:brief,:user => @user, :content => "asdf")}
      get :show, :id => @user
      response.should have_selector('td.sidebar', :content => @user.briefs.count.to_s)
    end
    describe "when signed in as another user" do
      it "should be successful" do
        test_sign_in(Factory(:user, :email => Factory.next(:email)))
        get :show, :id => @user
        response.should be_success
      end
    end
 end
 
  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end
    
    it "should have the right title" do
      get :new
      response.should have_selector('title', :content => "Sign Up")
    end
  end
  
  describe "POST 'create'" do
    
    describe "failure" do
      before (:each) do
        @atttr = { :name => "", :email => "", :password => "", :password_confirmation => ""}
      end
      it "should not create a user" do
        lambda do 
          post :create, :user => @attr
        end.should_not change(User, :count)
      end
      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector('title', :content => "Sign up")
      end
      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end
    end
    
    describe "success" do

          before(:each) do
            @attr = { :name => "New User", :email => "user@example.com",
                      :password => "foobar", :password_confirmation => "foobar" }
          end

          it "should create a user" do
            lambda do
              post :create, :user => @attr
            end.should change(User, :count).by(1)
          end

          it "should redirect to the user show page" do
            post :create, :user => @attr
            response.should redirect_to(user_path(assigns(:user)))
          end    
          it "should have a welcome message" do
            post :create, :user => @attr
           flash[:success].should =~ /Welcome to InternAdmin/i
          end
          it "should sign the user in" do
            post :create, :user => @attr
            controller.should be_signed_in
          end
        end
      end
  describe "GET 'edit'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end

    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector("title", :content => "Edit Intern")
    end
  end
  describe "PUT 'update'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    describe "failure" do

      before(:each) do
        @attr = { :email => "", :name => "", :password => "",
                  :password_confirmation => "" }
      end

      it "should make 'edit' " do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end

      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector("title", :content => "Edit Intern")
      end
    end

    describe "success" do

      before(:each) do
        @attr = { :name => "Joe Example", :email => "Joe@example.edu",
                  :password => "sixletter", :password_confirmation => "sixletter" }
      end

      it "should change the user's entry" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.name.should  == @attr[:name]
        @user.email.should == @attr[:email]
      end

      it "should send to My Residents page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end

      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/i
      end
    end
  end
  describe "authentication of edit/update action" do

    before(:each) do
      @user = Factory(:user)
    end

    describe "for unsigned in" do

      it "should not allow 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /signed in/i
      end

      it "should not allow 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end
    end
    describe "for signed in" do
      before(:each) do
        bad_user = Factory(:user, :email => "bad@example.com")
        test_sign_in(bad_user)
      end
      it "should be a valid user for edit" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end
      it "should not allow 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end
  end
  describe "DELETE 'destroy'" do
    before(:each) do
      @user = Factory(:user)
    end
    describe "someone not signed in" do
      it "should description" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end
    describe "not an admin" do
      it "should not allow destroy" do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end
    describe "admin allowances" do
      before (:each) do
        @admin = Factory(:user, :email => "admin@internadmin.com", :admin => true)
        test_sign_in(@admin)
      end
      it "should dstroy users" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end
      it "should redirect to interns page" do
        delete :destroy, :id => @user
        flash[:success].should =~ /deleted/i
        response.should redirect_to(users_path)
      end 
      it "can't destroy itself" do
        lambda do
          delete :destroy, :id => @admin
        end.should_not change(User,:count).by(-1)
      end
    end
  end
  describe "follow pages" do

    describe "when not signed in" do
      it "should protect 'stalking'" do
        get :stalking, :id => 1
        response.should redirect_to(signin_path)
      end

      it "should protect 'followers'" do
        get :followers, :id => 1
        response.should redirect_to(signin_path)
      end
    end

    describe "when signed in" do

      before(:each) do
        @user = test_sign_in(Factory(:user))
        @other_user = Factory(:user, :email => Factory.next(:email))
        @user.stalk!(@other_user)
      end

      it "should show user stalking" do
        get :stalking, :id => @user
        response.should have_selector("a", :href => user_path(@other_user),
                                           :content => @other_user.name)
      end

      it "should show user followers" do
        get :followers, :id => @other_user
        response.should have_selector("a", :href => user_path(@user),
                                           :content => @user.name)
      end
    end
  end
end








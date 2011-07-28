require 'spec_helper'

describe RelationsController do

  describe "access control" do

    it "should require signin for create" do
      post :create
      response.should redirect_to(signin_path)
    end

    it "should require signin for destroy" do
      delete :destroy, :id => 1
      response.should redirect_to(signin_path)
    end
  end

  describe "POST 'create'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
      @stalked = Factory(:user, :email => Factory.next(:email))
    end

    it "should use ajax" do
      lambda do
        xhr :post, :create, :relation => { :stalked_id => @stalked }
        response.should be_success
      end.should change(Relation, :count).by(1)
    end
  end

  describe "DELETE 'destroy'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
      @stalked = Factory(:user, :email => Factory.next(:email))
      @user.stalk!(@stalked)
      @relation = @user.relations.find_by_stalked_id(@stalked)
    end

  
    it "should use ajax" do
      lambda do
        xhr :delete, :destroy, :id => @relation
        response.should be_success
      end.should change(Relation, :count).by(-1)
    end
  end
end

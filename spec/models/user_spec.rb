require 'spec_helper'

describe User do
  
  before (:each) do
    @attr = {:name => "Example User", 
            :email => "user@example.com",
            :password => "foobar",
            :password_confirmation => "foobar",
            }
  end
  
  it "should create a new instance given a valid attribute" do 
    User.create!(@attr)
  end
  
  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end
  
  it "should require an email" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end
  
  it "should reject names that are too long" do
    long_name = "a"*51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end
  
  
  it "should accept valid email addresses" do
      addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
      addresses.each do |address|
        valid_email_user = User.new(@attr.merge(:email => address))
        valid_email_user.should be_valid
      end
    end
  
  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com THE_USER_at_foo.bar.org first.last@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate email addresses" do
     # Put a user with given email address into the database.
     User.create!(@attr)
     user_with_duplicate_email = User.new(@attr)
     user_with_duplicate_email.should_not be_valid
   end
   
  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  describe "passwords" do
    before(:each) do
      @user = User.new(@attr)
    end
    
    it "should have a password attribute" do
      @user.should respond_to(:password)
    end
    it "should have a password confirmation" do 
      @user.should respond_to(:password_confirmation)
    end
  end
  
  describe "password validations"do
    it "should require password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
        should_not be_valid
    end  
    it "should require a matching password confirmation" do
         User.new(@attr.merge(:password_confirmation => "invalid")).
           should_not be_valid
    end
    
    it "should reject short passwords" do
         short = "a" * 5
          hash = @attr.merge(:password => short, :password_confirmation => short)
          User.new(hash).should_not be_valid
        end

        it "should reject long passwords" do
          long = "a" * 41
          hash = @attr.merge(:password => long, :password_confirmation => long)
          User.new(hash).should_not be_valid
        end
      end
  describe "password encryption" do
    before (:each) do 
      @user = User.create!(@attr)
    end
    it "should have an encrytped password attribute" do
      @user.should respond_to(:encrypted_password)
    end
    it "should set the encrypted password attribute" do
      @user.encrypted_password.should_not be_blank
    end
    it "should have a salt" do
      @user.should respond_to(:salt)
    end
    describe "has password?" do
      it "should exist" do
        @user.should respond_to(:has_password?)
    end
    
    it "should return true if the passwords match" do
      @user.has_password?(@attr[:password]).should be_true
    end
    
    it "should return false if the passwords dont match" do
      @user.has_password?("invalid").should be_false
    end
  end
  describe "authenticate method" do
    it "should exist" do
      User.should respond_to(:authenticate)
    end  
    
    it "should return nil on email/password mismatch" do
      wrong_pass_user = User.authenticate(@attr[:email], "shittypass")
      wrong_pass_user.should be_nil
    end
    
    it "should return nil for an email address with no user" do
      no_user = User.authenticate("shittyuser", @attr[:password])
      no_user.should be_nil
    end
    
    it "should return the user on email/password match" do
      good_user = User.authenticate(@attr[:email], @attr[:password])
      good_user.should == @user
    end
  end
end

  describe "administrator" do
    before (:each) do
      @user = User.create!(@attr)
    end
    it "a user should have admin attribute" do
      @user.should respond_to(:admin)
    end
    it "should only have some users be admin" do
      @user.should_not be_admin
    end
    it "should be able to make users into admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end
  describe "brief associations" do
    before(:each) do
      @user = User.create(@attr)
      @b1 = Factory(:brief, :user => @user, :created_at => 1.day.ago)
      @b2 = Factory(:brief, :user => @user, :created_at => 1.hour.ago)
    end
    it "should have a briefs attribute" do
      @user.should respond_to(:briefs)
    end
    it "should brief in the right order" do
      @user.briefs.should == [@b2, @b1]
    end
    describe "status feed" do
      it "should have a feed" do
        @user.should respond_to(:feed)
      end
      it "should include the user's briefs" do
        @user.feed.should include(@b1)
        @user.feed.should include(@b2)
      end
      it "should not include a different user's briefs" do
        b3 = Factory(:brief,
                      :user => Factory(:user, :email => Factory.next(:email)))
        @user.feed.should_not include(b3)
      end
      it "should include the briefs of followed users" do
        stalked = Factory(:user, :email => Factory.next(:email))
        b3 = Factory(:brief, :user => stalked)
        @user.stalk!(stalked)
        @user.feed.should include(b3)
      end
    end
  end
  describe "relations" do
    before(:each) do
      @user = User.create!(@attr)
      @stalked = Factory(:user)
    end
    it "should have a relations method" do
      @user.should respond_to(:relations)
    end
    it "should have a stalking method" do
      @user.should respond_to(:stalking)
    end
    it "should have a stalking? method" do
      @user.should respond_to(:stalking?)
    end
    it "should stalk another user" do
      @user.stalk!(@stalked)
      @user.should be_stalking(@stalked)
    end
    it "should have a stalk! method" do
      @user.should respond_to(:stalk!)
    end
   
    it "should include the stalked user in the stalking array" do
      @user.stalk!(@stalked)
      @user.stalking.should include(@stalked)
    end
    it "should have an unstalk method" do
      @stalked.should respond_to(:unstalk!)
    end
    it "should unstalk a user" do
      @user.stalk!(@stalked)
      @user.unstalk!(@stalked)
      @user.should_not be_stalking(@stalked)
    end
    it "should have a reverse_relations method" do
      @user.should respond_to(:reverse_relations)
    end
    it "should have a followers method" do
      @user.should respond_to(:followers)
    end
    it "should include the stalker in the stalkers array" do
      @user.stalk!(@stalked)
      @stalked.followers.should include(@user)
    end
  end
end



# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean         default(FALSE)
#


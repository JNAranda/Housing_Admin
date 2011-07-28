require 'spec_helper'

describe Brief do
  before(:each) do
    @user = Factory(:user)
    @attr = { :content => "floasfasffaaff", :user_id =>1 }
  end
  it "should create a new entry with the right attr" do
    @user.briefs.create!(@attr)
  end
  describe "user associations" do
    before(:each)do
      @brief = @user.briefs.create(@attr)
    end
    it "shouldhave a user attr" do
      @brief.should respond_to(:user)
    end    
    it "should have the right user assignment" do
      @brief.user_id.should == @user.id
      @brief.user.should == @user
    end
  end  
  describe "validations" do
    
    it "should have a user id" do
      Brief.new(@attr).should_not be_valid
    end
    it "should have content" do
      @user.briefs.build(:content => "   ").should_not be_valid
    end
    it "should not have ungodly content" do
      @user.briefs.build(:content => "a"*1001).should_not be_valid
    end
  end
  describe "from_users_stalked_by" do

    before(:each) do
      @other_user = Factory(:user, :email => Factory.next(:email))
      @third_user = Factory(:user, :email => Factory.next(:email))

      @user_brief  = @user.briefs.create!(:content => "foo")
      @other_brief = @other_user.briefs.create!(:content => "bar")
      @third_brief = @third_user.briefs.create!(:content => "baz")

      @user.stalk!(@other_user)
    end

    it "should have a from_users_stalked_by class method" do
      Brief.should respond_to(:from_users_stalked_by)
    end

    it "should include the followed user's briefs" do
      Brief.from_users_stalked_by(@user).should include(@other_brief)
    end

    it "should include the user's own briefs" do
      Brief.from_users_stalked_by(@user).should include(@user_brief)
    end

    it "should not include an unfollowed user's briefs" do
      Brief.from_users_stalked_by(@user).should_not include(@third_brief)
    end
  end
end


# == Schema Information
#
# Table name: briefs
#
#  id         :integer         not null, primary key
#  content    :text
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#


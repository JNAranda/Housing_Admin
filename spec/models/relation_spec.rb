require 'spec_helper'

describe Relation do
  before(:each) do
    @follower = Factory(:user)
    @stalked = Factory(:user, :email => Factory.next(:email))
    @relation = @follower.relations.build(:stalked_id => @stalked.id)
  end
  it "should create a new entry with good attr" do
    @relation.save!
  end
  describe "follow methods" do
     before(:each) do
      @relation.save!
    end
    it "should have a follower attribute" do
      @relation.should respond_to(:follower)
    end
    it "should have the right follower" do
      @relation.follower.should == @follower
    end
    it "should have a followed attribute" do
      @relation.should respond_to(:stalked)
    end
    it "should have the right stalked user" do
      @relation.stalked.should == @stalked
    end
  end
  describe "validation" do
    it "should require a follower_id" do
      Relation.new(@attr).should_not be_valid
    end
    it "should require a stalked_id" do
     @follower.relations.build.should_not be_valid  
    end
  end
end

# == Schema Information
#
# Table name: relations
#
#  id          :integer         not null, primary key
#  follower_id :integer
#  stalked_id  :integer
#  created_at  :datetime
#  updated_at  :datetime
#


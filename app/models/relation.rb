class Relation < ActiveRecord::Base
  attr_accessible :stalked_id
  belongs_to :follower, :foreign_key => "follower_id",  :class_name => "User"
  belongs_to :stalked, :foreign_key => "stalked_id", :class_name => "User"
  
  validates :follower_id, :presence => true
  validates :stalked_id, :presence => true
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


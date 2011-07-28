class Brief < ActiveRecord::Base
  attr_accessible :content
  
  belongs_to :user
  validates :content, :presence => true, :length => { :maximum => 1000}
  validates :user_id, :presence => true
  default_scope :order => 'briefs.created_at DESC'
  scope :from_users_stalked_by, lambda { |user| stalked_by(user) }
  private
  
    def self.stalked_by(user)
      stalked_ids = %(SELECT stalked_id FROM relations WHERE follower_id = :user_id)
      where("user_id IN (#{stalked_ids}) or user_id = :user_id", :user_id => user )
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


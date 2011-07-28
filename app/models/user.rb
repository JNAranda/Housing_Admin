class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation
  attr_accessor :password
  has_many :briefs
  has_many :relations, :foreign_key => "follower_id"
  has_many :stalking, :through => :relations, :source => :stalked
  has_many :reverse_relations, :foreign_key => "stalked_id",
                              :class_name => "Relation"
  has_many :followers, :through => :reverse_relations, :source => :follower
  
  
  email_regex = /\A[\w+\-.]+@[a-z.\d\-]+\.[a-z]+\z/i
  
  validates :name, :presence => true,
                   :length => {:maximum => 50}
  validates :email, :presence => true,
                  :format => {:with => email_regex},
                  :uniqueness => { :case_sensitive => false }
  validates :password, :presence => true,
                        :confirmation => true,
                        :length => { :within => 6..40 }
  before_save :encrypt_password
  #scope :admin, where(:admin => true)
  
  
  def has_password?(submitted_password)
      encrypted_password == encrypt(submitted_password)
  end
  def stalking?(stalked)
    relations.find_by_stalked_id(stalked)
  end 
  def stalk!(stalked)
    relations.create!(:stalked_id => stalked.id)
  end
  def unstalk!(stalked)
    relations.find_by_stalked_id(stalked).destroy
  end
  def feed
    Brief.from_users_stalked_by(self)
  end
  class << self
    def authenticate(email, submitted_password)
        user = find_by_email(email)
        (user && user.has_password?(submitted_password)) ? user : nil  
    end
    
    def authenticate_with_salt(id, cookie_salt)
        user = find_by_id(id)
        (user && user.salt == cookie_salt) ? user : nil
    end
  end
 
 
  private
    def encrypt_password
      self.salt = make_salt if self.new_record?
      self.encrypted_password = encrypt(self.password)
    end
    
    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end
    
    def encrypt(string)
      secure_hash("#{self.salt}--#{string}")
    end
    
    def secure_hash(string) 
      Digest::SHA2.hexdigest(string)
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


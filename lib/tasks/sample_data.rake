require 'faker'

namespace :db do
  desc "fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    make_users
    make_briefs
    make_relations  
  end
end
def make_users
    admin = User.create!(:name => "Joe Example",
                 :email => "Joe@example.com",
                 :password => "sixletter",
                 :password_confirmation => "sixletter")
    admin.toggle!(:admin)
    15.times do |n|
      name = Faker::Name.name
      email = "example-#{n+1}@example.com"
      password = "sixletter"
      User.create!(:name => name,
                   :email => email,
                   :password => password,
                   :password_confirmation => password)
   end
end

def make_briefs
    User.all(:limit => 3).each do |user|
      50.times do
        user.briefs.create!(:content => Faker::Lorem.sentence(5))
      end
    end
end

def make_relations
  users = User.all
  user = users.first
  stalking = users[1..15]
  followers = users[3..13]
  stalking.each { |stalked| user.stalk!(stalked) }
  followers.each { |follower| follower.stalk!(user) }
end
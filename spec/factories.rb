Factory.define :user do |user|
  user.name   "Joe Aranda"
  user.email "joe@example.com"
  user.password "nicyng4"
  user.password_confirmation "nicyng4"
  
end
Factory.sequence :email do |n|
  "person-#{n}@example.com"  
end

Factory.define :brief do |brief|
  brief.content "still i feel as if everything has passed me by"
  brief.association :user
end
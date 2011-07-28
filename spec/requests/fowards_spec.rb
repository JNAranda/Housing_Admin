require 'spec_helper'

describe "forwards" do
  it "should forward to the desired page after signing in" do
    user = Factory(:user)
    visit edit_user_path(user)
    fill_in :email, :with => user.email
    fill_in :password, :with => user.password
    click_button
    response.should render_template('users/edit')
 
  end
end

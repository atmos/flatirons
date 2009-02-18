describe "Signup up for an account" do
  it "display a form requesting your email address" do
    visit '/users/new'

    response.should have_selector("form[action='/users'][method='post']")
    response.should have_selector("input#login[type='text'][name='login'][value='']")
    response.should have_selector("input#email[type='text'][name='email'][value='']")
  end
end

describe "Confirming Registration Link" do
  it "tells you that you're awesome" do
    visit '/users/new'

    fill_in 'login', :with => 'arthur'
    fill_in 'email', :with => 'arthur@example.com'
    click_button 'Create'
    sleep 1

    user = User.first(:login => 'arthur')
    visit "/users/signup?token=#{user.registration_token}"

    response.should have_selector("h2:contains('You are so awesome')")
    response.should have_selector("form[action='/users/#{user.id}']")
    response.should have_selector("input[type='hidden'][name='_method'][value='put']")
    response.should have_selector("input#user_login[value='arthur'][type='text']")
    response.should have_selector("input#user_email[type='text'][value='arthur@example.com']")
    response.should have_selector("input#user_password[type='password']")
    response.should have_selector("input#user_password_confirmation[type='password']")
    sleep 2

    password = Digest::SHA1.hexdigest(Time.now.to_s)
    fill_in 'user_password', :with => password
    fill_in 'user_password_confirmation', :with => password
    click_button 'Update'

    sleep 4
  end
end

#describe "Deleting Quentin's account", :given => 'an authenticated user' do
#  before(:each) { setup_user }
#  it "delete quentin's account successfully" do
#    response = request("/users/quentin", :method => 'delete')
#    response.should redirect_to(url(:new_user))
#  end
#end

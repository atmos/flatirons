describe "Signup up for an account" do
  it "display a form requesting your email address" do
    response = request("/users/new")
    response.should be_successful
    response.should have_selector("form[action='/users'][method='post']")
    response.should have_selector("input#login[type='text'][name='login'][value='']")
    response.should have_selector("input#email[type='text'][name='email'][value='']")
  end
end

describe "Confirming Registration Link" do
  it "tells you that you're awesome" do
    response = request("/users/new")
    response.should be_successful
    response.should have_selector("form[action='/users'][method='post']")
    response.should have_selector("input#login[type='text'][name='login'][value='']")
    response.should have_selector("input#email[type='text'][name='email'][value='']")

    response = request("/users", :method => 'post', 
                       :params => {:login => 'arthur', :email => 'arthur@example.com'})
    response.should redirect_to(url(:perform_login))
    response = request("/users/signup", 
                       :params => {:token => User.first(:login => 'arthur').registration_token})
    response.should be_successful
    response.should have_selector("h2:contains('You are so awesom')")
    response.should have_selector("form[action='/users']")
    response.should have_selector("input[type='hidden'][name='_method'][value='put']")
    response.should have_selector("input#login[type='text'][name='login'][value='arthur']")
    response.should have_selector("input#email[type='text'][name='email'][value='arthur@example.com']")
    response.should have_selector("input#password[type='password'][name='password']")
    response.should have_selector("input#password_confirmation[type='password'][name='password_confirmation']")
  end
end

describe "Deleting Quentin's account", :given => 'an authenticated user' do
  before(:each) { setup_user }
  it "delete quentin's account successfully" do
    response = request("/users/quentin", :method => 'delete')
    response.should redirect_to(url(:new_user))
  end
end

describe "User Landing Page" do
  describe "requesting / when unauthenticated" do
    it "should force the user to login" do
      visit '/'
      response.should be_a_valid_merb_auth_form
    end
    it "should display form errors if they enter a bad username/password" do
      visit '/'
      response.should be_a_valid_merb_auth_form
      fill_in 'login', :with => 'quentin'
      fill_in 'password', :with => 'foobarbaz'
      click_button 'Log in'

      response.should be_a_valid_merb_auth_form
      response.should have_selector("div.content div.error h2:contains('Unable to login')")
    end
  end
  describe "requesting / when authenticated", :given => 'an authenticated user' do
    it "should display the landing page" do
      visit '/'

      response.should have_selector("p a[href='http://www.powerset.com/explore/semhtml/Flatirons?query=what+are+the+flatirons']")
      response.should have_selector("p a[href='http://github.com/atmos/flatirons/tree/master']")
    end
  end
end

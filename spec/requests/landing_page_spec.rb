describe "User Landing Page" do
  describe "requesting / when unauthenticated" do
    it "should force the user to login" do
      response = request("/")
      response.should be_a_valid_merb_auth_form
    end
    it "should display form errors if they enter a bad username/password" do
      response = request("/")
      response.should be_a_valid_merb_auth_form
      response = request "/login", :method => "PUT", 
                                   :params => { :login => 'quentin', :password => 'foobarbaz' }
      response.should be_a_valid_merb_auth_form
      response.should have_selector("div.content div.error h2:contains('Unable to login')")
    end
  end
  describe "requesting / when authenticated", :given => 'an authenticated user' do
    it "should display the landing page" do
      response = request("/")
      response.should be_successful
      response.should have_selector("p a[href='http://www.powerset.com/explore/semhtml/Flatirons?query=what+are+the+flatirons']")
      response.should have_selector("p a[href='http://github.com/atmos/flatirons/tree/master']")
    end
  end
end

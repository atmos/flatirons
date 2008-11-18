describe Servers do
  describe "requesting / while unauthenticated" do
    it "should force the user to login" do
      response = request("/")
      response.should be_a_valid_merb_auth_form
    end
  end
  describe "requesting /", :given => 'an authenticated user' do
    it "should force the user to login" do
      response = request("/")
      response.should be_successful
      response.should have_xpath("//p/a[@href='http://www.powerset.com/explore/semhtml/Flatirons?query=what+are+the+flatirons']")
      response.should have_xpath("//p/a[@href='http://github.com/atmos/flatirons/tree/master']")
    end
  end
end

describe Servers do
  describe "#acceptance" do
    it "should redirect to the login page" do
      response = request("/servers/acceptance")
      response.status.should == 401
    end
  end
  describe "#acceptance", :given => 'an authenticated user requesting auth' do
    it "should return HTTP success and display the acceptance form" do
      response = request("/servers/acceptance")
      response.should be_successful
      response.should have_xpath("//form[@action='/servers/decision' and @method='post']")
    end
  end
end

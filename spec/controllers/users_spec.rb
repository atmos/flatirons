require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Users, "#show" do
  describe "accepting xrds+xml" do
    it "renders the user's identity page(/users/atmos@atmos.org)" do
      response = request("/users/atmos@atmos.org", {'HTTP_ACCEPT' => 'application/xrds+xml'})
      response.should be_successful
      response.headers["X-XRDS-Location"].should == "http://example.org/users/atmos@atmos.org/xrds"
      response.body.should have_xpath("//xrd/service[uri='http://example.org/servers']")
      response.body.should have_xpath("//xrd/service[type='http://specs.openid.net/auth/2.0/signon']")
      response.body.should have_xpath("//xrd/service[type='http://openid.net/sreg/1.0']")
    end
    it "gracefully handles non-existent user requests(/users/joejoejoe)" do
      response = request("/users/joejoejoe@atmos.org", {'HTTP_ACCEPT' => 'application/xrds+xml'})
      response.status.should == 404
    end
  end

  describe "accepting text/html" do
    it "renders the user's identity page(/users/atmos@atmos.org)" do
      response = request("/users/atmos@atmos.org")
      response.should be_successful
      response.body.should have_xpath("//link[@rel='openid.server' and @href='http://example.org/servers']")
      response.body.should have_xpath("//meta[@http-equiv='X-XRDS-Location' and @content='http://example.org/users/atmos@atmos.org/xrds']")
      response.body.should have_xpath("//body[p='OpenID identity page for atmos@atmos.org']")
      response.headers["X-XRDS-Location"].should == "http://example.org/users/atmos@atmos.org/xrds"
    end
  end
  
  it "should handle routing for /users/atmos@atmos.org/xrds properly" do
    request_to("/users/atmos@atmos.org/xrds", :get, {:http_accept => 'application/xrds+xml'}).
      should route_to(Users, :show).with(:email => 'atmos@atmos.org')
  end
end

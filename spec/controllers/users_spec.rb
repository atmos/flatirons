require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Users, "#show" do
  describe "accepting xrds+xml" do
    it "renders the user's identity page(/users/atmos)" do
      response = request("/users/atmos", {'HTTP_ACCEPT' => 'application/xrds+xml'})
      response.should be_successful
      response.headers["X-XRDS-Location"].should == "http://example.org/users/atmos/xrds"
      response.body.should have_xpath("//xrd/service[uri='http://example.org/servers']")
      response.body.should have_xpath("//xrd/service[type='http://specs.openid.net/auth/2.0/signon']")
      response.body.should have_xpath("//xrd/service[type='http://openid.net/signon/1.0']")
      response.body.should have_xpath("//xrd/service[type='http://openid.net/sreg/1.0']")
    end
  end

  describe "accepting text/html" do
    it "renders the user's identity page(/users/atmos)" do
      response = request("/users/atmos")
      response.should be_successful
      response.body.should have_xpath("//link[@rel='openid.server' and @href='http://example.org/servers']")
      response.body.should have_xpath("//meta[@http-equiv='X-XRDS-Location' and @content='http://example.org/users/atmos/xrds']")
      response.body.should have_xpath("//body[p='OpenID identity page for atmos']")
      response.headers["X-XRDS-Location"].should == "http://example.org/users/atmos/xrds"
    end
  end
  
  it "should handle routing for /users/atmos/xrds properly" do
    request_to("/users/atmos/xrds", :get, {:http_accept => 'application/xrds+xml'}).
      should route_to(Users, :show).with(:id => 'atmos')
  end
end

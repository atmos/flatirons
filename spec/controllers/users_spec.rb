describe Users, "#show" do
  before(:each) { setup_user }
  describe "accepting xrds+xml" do
    it "renders the user's identity page(/users/quentin)" do
      response = request("/users/quentin", {'HTTP_ACCEPT' => 'application/xrds+xml'})
      response.should be_successful
      response.headers["X-XRDS-Location"].should == "http://example.org/users/quentin/xrds"
      response.body.should have_xpath("//xrd/service[uri='http://example.org/servers']")
      response.body.should have_xpath("//xrd/service[type='http://specs.openid.net/auth/2.0/signon']")
      response.body.should have_xpath("//xrd/service[type='http://openid.net/sreg/1.0']")
    end
    it "gracefully handles non-existent user requests(/users/romeo)" do
      response = request("/users/romeo", {'HTTP_ACCEPT' => 'application/xrds+xml'})
      response.status.should == 404
    end
  end

  describe "accepting text/html" do
    it "renders the user's identity page(/users/quentin)" do
      response = request("/users/quentin")
      response.should be_successful
      response.body.should have_xpath("//link[@rel='openid.server' and @href='http://example.org/servers']")
      response.body.should have_xpath("//meta[@http-equiv='X-XRDS-Location' and @content='http://example.org/users/quentin/xrds']")
      response.body.should have_xpath("//body[p='OpenID identity page for quentin']")
      response.headers["X-XRDS-Location"].should == "http://example.org/users/quentin/xrds"
    end
  end
  
  it "should handle routing for /users/atmos@atmos.org/xrds properly" do
    request_to("/users/quentin/xrds", :get, {:http_accept => 'application/xrds+xml'}).
      should route_to(Users, :show).with(:id => 'quentin')
  end
end

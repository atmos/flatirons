describe "Identity Discovery" do
  before(:each) { setup_user }
  describe "accepting xrds+xml" do
    it "renders the user's identity page(/users/quentin)" do
      response = request("/users/quentin", {'HTTP_ACCEPT' => 'application/xrds+xml'})
      response.should be_successful
      response.headers["X-XRDS-Location"].should == "http://example.org/users/quentin.xrds"
      response.should have_xpath("//xrd/service[uri='http://example.org/servers']")
      response.should have_xpath("//xrd/service[type='http://specs.openid.net/auth/2.0/signon']")
      response.should have_xpath("//xrd/service[type='http://openid.net/sreg/1.0']")
    end

    it "gracefully handles non-existent user requests(/users/romeo)" do
      response = request("/users/romeo", {'HTTP_ACCEPT' => 'application/xrds+xml'})
      response.status.should == 404
    end
  end

  describe "accepting text/html" do
    it "renders the user's identity page (/users/quentin)" do
      response = request("/users/quentin")
      response.should be_successful
      response.should have_selector("head link[rel='openid.server'][href='http://example.org/servers']")
      response.should have_selector("head meta[http-equiv='X-XRDS-Location'][content='http://example.org/users/quentin.xrds']")
      response.should have_selector("body p:contains('OpenID identity page for quentin')")
      response.headers["X-XRDS-Location"].should == "http://example.org/users/quentin.xrds"
    end
  end

  it "renders the user's identity page(/users/quentin.xrds)" do
    response = request("/users/quentin.xrds", {'HTTP_ACCEPT' => 'application/xrds+xml'})
    response.should be_successful
    response.headers["X-XRDS-Location"].should == "http://example.org/users/quentin.xrds"
    response.should have_xpath("//xrd/service[uri='http://example.org/servers']")
    response.should have_xpath("//xrd/service[type='http://specs.openid.net/auth/2.0/signon']")
    response.should have_xpath("//xrd/service[type='http://openid.net/sreg/1.0']")
  end

  it "should handle routing for /users/quentin.xrds properly" do
    request_to("/users/quentin.xrds", :get, {:http_accept => 'application/xrds+xml'}).
      should route_to(Users, :show).with(:id => 'quentin')
  end
end

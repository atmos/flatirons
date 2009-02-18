describe "Provider URL Information" do
  describe "accepting xrds+xml" do
    it "renders the identity provider's xrds page (/servers/xrds)" do
      http_accept('application/xrds+xml')
      visit('/servers/xrds')
#      response = request("/servers/xrds", {'HTTP_ACCEPT' => 'application/xrds+xml'})
#      response.should be_successful
      response.should have_xpath("//xrd/service[uri='http://example.org/servers']")
      response.should have_xpath("//xrd/service[type='http://specs.openid.net/auth/2.0/server']")
    end
  end
end

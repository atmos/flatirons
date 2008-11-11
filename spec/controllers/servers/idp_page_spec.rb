require File.dirname(__FILE__) + '/../../spec_helper'

describe Servers, "#idp_page" do
  describe "accepting xrds+xml" do
    it "renders the provider idp page" do
      response = request("/servers/xrds", {'HTTP_ACCEPT' => 'application/xrds+xml'})
      response.should be_successful
      response.body.should have_xpath("//xrd/service[uri='http://example.org/servers']")
      response.body.should have_xpath("//xrd/service[type='http://specs.openid.net/auth/2.0/signon']")
      response.body.should have_xpath("//xrd/service[type='http://openid.net/signon/1.0']")
      response.body.should have_xpath("//xrd/service[type='http://openid.net/sreg/1.0']")
    end
  end
  
  it "should handle routing for /servers/xrds properly" do
    request_to("/servers/xrds", :get, {:http_accept => 'application/xrds+xml'}).
      should route_to(Servers, :idp_page)
  end

end
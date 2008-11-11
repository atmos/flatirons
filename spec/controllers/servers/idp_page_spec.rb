require File.dirname(__FILE__) + '/../../spec_helper'

describe Servers do
  describe "provider(idp) accepting xrds+xml" do
    before(:each) do
      response = request("/servers/xrds", :http_accept => 'application/xrds+xml')
      response.should be_successful
      response.body.should match(%r!<URI>http://localhost/servers</URI>!)
    end
  end
  
  it "should handle routing for /servers/xrds properly" do
    request_to("/servers/xrds", :get, {:http_accept => 'application/xrds+xml'}).
      should route_to(Servers, :idp_page)
  end

end
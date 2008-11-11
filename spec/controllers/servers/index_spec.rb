require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Servers, "#index" do
  describe "empty params" do
    it "should raise errors" do
      response = request("/servers")
      response.status.should == 500
    end
  end

  describe " with openid parameters and authorized", :given => 'an returning user with trusted hosts in their session' do
    it "should redirect back to the consumer app with the appropriate query string" do
      params =  {"openid.mode"       =>"checkid_setup", 
                 "openid.return_to"  => 'http://consumerapp.com/',
                 'openid.identity'   => 'http://example.org/users/atmos',
                 'openid.claimed_id' => 'http://example.org/users/atmos'}

      response = request("/servers", :params => params)
    end
    it "should handle redirecting with all the applicable query parameters" do
      pending
      pp response
      # response.body.should match(%r!href="http://localhost?.*"!)
      redirect_params = query_parse(Addressable::URI.parse(response.headers['Location']).query)
      pp redirect_params
      %w(ns ns.sreg sreg.nickname sreg.email claimed_id identity mode op_endpoint assoc_handle response_nonce signed).each do |k|
        redirect_params["openid.#{k}"].should_not be_nil
      end
    end
  end
  
  describe "with openid parameters but unauthorized", :given => 'an authenticated user' do
    it "should redirect to the acceptance page" do
      params =  {"openid.mode"       =>"checkid_setup", 
                 "openid.return_to"  => 'http://consumerapp.com/',
                 'openid.identity'   => 'http://example.org/users/atmos',
                 'openid.claimed_id' => 'http://example.org/users/atmos'}
      response = request("/servers", :params => params)
      response.should redirect_to('/servers/acceptance')
    end
  end
  
  describe "with openid mode of immediate", :given => 'an authenticated user' do
    it "should redirect to the client with a user_setup_url" do
      params =  {"openid.mode"       =>"checkid_immediate", 
                 "openid.return_to"  => 'http://consumerapp.com/',
                 'openid.identity'   => 'http://example.org/users/atmos',
                 'openid.claimed_id' => 'http://example.org/users/atmos'}

      response = request("/servers", :params => params)
      response.status.should == 302
      redirect_params = query_parse(Addressable::URI.parse(response.headers['Location']).query)
      %w(user_setup_url mode sig assoc_handle signed).each do |k|
        redirect_params["openid.#{k}"].should_not be_nil
      end
    end
    
  end
end

describe Servers, "#index" do
  describe "empty params" do
    it "should let you know about the flatirons(users shouldn't ever hit this but you can customize it)" do
      response = request("/servers")
      response.should be_successful
      response.should have_xpath("//p/a[@href='http://www.powerset.com/explore/semhtml/Flatirons?query=what+are+the+flatirons']")
      response.should have_xpath("//p/a[@href='http://github.com/atmos/flatirons/tree/master']")
    end
  end

  describe " with openid parameters and authorized", :given => 'an returning user with trusted hosts in their session' do
    it "should redirect back to the consumer app with the appropriate query string" do
      params =  {"openid.mode"       => "checkid_setup", 
                 "openid.return_to"  => 'http://consumerapp.com/',
                 'openid.identity'   => 'http://example.org/users/quentin',
                 'openid.claimed_id' => 'http://example.org/users/quentin'}

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
  
  describe "with openid parameters but unauthorized" do
    it "should redirect to the acceptance page(and /login if needed)" do
      params =  {"openid.mode"       => "checkid_setup", 
                 "openid.return_to"  => 'http://consumerapp.com/',
                 'openid.identity'   => 'http://example.org/users/quentin',
                 'openid.claimed_id' => 'http://example.org/users/quentin'}
      response = request("/servers", :params => params)
      response.should redirect_to('/servers/acceptance')
    end
  end
  
  describe "with openid mode of immediate", :given => 'an authenticated user' do
    it "should redirect to the client with a user_setup_url" do
      params =  {"openid.mode"       => "checkid_immediate", 
                 "openid.return_to"  => 'http://consumerapp.com/',
                 'openid.identity'   => 'http://example.org/users/quentin',
                 'openid.claimed_id' => 'http://example.org/users/quentin'}

      response = request("/servers", :params => params)
      response.status.should == 302
      redirect_params = query_parse(Addressable::URI.parse(response.headers['Location']).query)
      %w(user_setup_url mode sig assoc_handle signed).each do |k|
        redirect_params["openid.#{k}"].should_not be_nil
      end
    end
  end
  describe "with openid mode of associate" do
    it "should redirect to the client with a user_setup_url" do
      params =  {"openid.mode"         => "associate",
                 "openid.session_type" => 'DH-SHA1',
                 "openid.assoc_type"   => 'HMAC-SHA1',
                 "openid.dh_consumer_public"=>"LXkAlLpfrKNX7+Pu6oKs/x1ca+zjPz/kRFpaFo+h9XnryEGcMmcF0e4ce2QlGRC4sseupPbRetrptTYJBWtclVg3Ton4KT8ePxcTJqtZ5Q6a4GXQxdFPLlmhZpFsXp8ik2Y487Ko9WMdM7hctitFV4Czm5bSpR/YXPbLwqDQg48="}

      response = request("/servers", :params => params)
      response.should be_successful
      
      body = response.body.to_s.split(/\n/).inject({}) do |sum, part|
        k, v = part.split(/:/)
        sum[k] = v
        sum
      end
      
      body.should_not be_nil
      body['assoc_type'].should       == 'HMAC-SHA1'
      body['assoc_handle'].should     =~ %r!\{HMAC-SHA1\}\{\w{8}\}\{[^\]]{8}!
      body['session_type'].should     == 'DH-SHA1'
      body['enc_mac_key'].size.should == 28
      body['dh_server_public']        == 'W9Orfz0HHHnqDl74gCj35FIE6gyR7WY+T4qEoufMSgjKP+40mUyNS8rzLw5ghUGHMd+NojgU1aWWVOQ5RCaz0d7qvix1xx2UZpFaLi+vEpcgLputRVkROeMWglvbAZbySA0mJ20vx5Qyu0gs3GtuWlM4StGHI2EoCou/V7CDVc='
    end
  end
end

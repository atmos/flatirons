describe Servers, "#index" do
  describe "requesting /servers without an openid mode" do
    it "should return Http Bad Request" do
      response = request("/servers")
      response.status.should == 400
    end

  end

  describe " with openid parameters and authorized", :given => 'an returning user with trusted hosts in their session' do
    it "should redirect back to the consumer app with the appropriate query string" do
      response = request("/servers", :params => default_request_parameters)
      response.status.should == 302

#      redirect_params = Addressable::URI.parse(response.headers['Location']).query_values
#
#      %w(ns ns.sreg sreg.nickname sreg.email claimed_id identity mode op_endpoint assoc_handle response_nonce signed).each do |k|
#        redirect_params["openid.#{k}"].should_not be_nil
#      end
    end
    it "should handle redirecting with all the applicable query parameters" do
      pending
      response = request("/servers", :params => default_request_parameters)
      response.status.should == 302
      redirect_params = query_parse(Addressable::URI.parse(response.headers['Location']).query)
      %w(ns ns.sreg sreg.nickname sreg.email claimed_id identity mode op_endpoint assoc_handle response_nonce signed).each do |k|
        redirect_params["openid.#{k}"].should_not be_nil
      end
    end
  end

  describe "with openid parameters but unauthorized" do
    it "should redirect to the acceptance page(and /login if needed)" do
      response = request("/servers", :params => default_request_parameters)
      response.should be_a_valid_merb_auth_form
    end
  end

  describe "with openid mode of immediate", :given => 'an authenticated user' do
    it "should redirect to the client with a user_setup_url" do
      params =  default_request_parameters.merge({
                    "openid.mode" => "checkid_immediate",
                    "openid.return_to"  => 'http://consumerapp.com/'})

      response = request("/servers", :params => params)
      response.status.should == 302
#      redirect_params = query_parse(Addressable::URI.parse(response.headers['Location']).query)
#      %w(user_setup_url mode sig assoc_handle signed).each do |k|
#        redirect_params["openid.#{k}"].should_not be_nil
#      end
    end
  end
  describe "with openid mode of associate" do
    it "should respond with Diffie Hellman data in kv format" do
      session = OpenID::Consumer::AssociationManager.create_session("DH-SHA1")
      params =  default_request_parameters.merge({
                    "openid.mode"         => "associate",
                    "openid.session_type" => 'DH-SHA1',
                    "openid.assoc_type"   => 'HMAC-SHA1',
                    "openid.dh_consumer_public"=> session.get_request['dh_consumer_public']})

      response = request("/servers", :params => params)
      response.should be_successful

      message = OpenID::Message.from_kvform(response.body)
      secret = session.extract_secret(message)
      secret.should_not be_nil

      args = message.get_args(OpenID::OPENID_NS)

      args['assoc_type'].should       == 'HMAC-SHA1'
      args['assoc_handle'].should     =~ /^\{HMAC-SHA1\}\{[^\}]{8}\}\{[^\}]{8}\}$/
      args['session_type'].should     == 'DH-SHA1'
      args['enc_mac_key'].size.should == 28
      args['expires_in'].should       =~ /^\d+$/
      args['dh_server_public'].size.should == 172
    end
  end
end

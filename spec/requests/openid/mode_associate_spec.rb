describe "OpenID Mode: Associate" do
  describe "with openid mode of associate" do
    it "should respond with Diffie Hellman data in kv format" do
      session = OpenID::Consumer::AssociationManager.create_session("DH-SHA1")
      params =  default_request_parameters.merge({
                    "openid.mode"         => "associate",
                    "openid.session_type" => 'DH-SHA1',
                    "openid.assoc_type"   => 'HMAC-SHA1',
                    "openid.dh_consumer_public"=> session.get_request['dh_consumer_public']})

      visit '/servers', :get, params

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

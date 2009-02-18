describe "OpenID Mode: Immediate" do
  describe "with openid mode of immediate", :given => 'an authenticated user' do
    it "should redirect to the client with a user_setup_url" do
      params =  default_request_parameters.merge({
                    "openid.mode" => "checkid_immediate",
                    "openid.return_to"  => 'http://consumerapp.com/'})

      visit("/servers", :get, params)
      response.status.should == 302
#      redirect_params = query_parse(Addressable::URI.parse(response.headers['Location']).query)
#      %w(user_setup_url mode sig assoc_handle signed).each do |k|
#        redirect_params["openid.#{k}"].should_not be_nil
#      end
    end
  end
end

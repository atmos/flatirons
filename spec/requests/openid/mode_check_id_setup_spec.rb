describe "OpenID Mode: CheckID Setup" do
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
end

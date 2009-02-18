describe "requesting /servers" do
  describe "No OpenID Mode Set" do
    it "should return Http BadRequest" do
      visit '/servers'
    end
  end
  describe "requesting OpenID Mode: CheckID Setup" do
    describe " with valid openid 2.0 parameters when authenticated", :given => 'an returning user with trusted hosts in their session' do
      it "should redirect back to the consumer app with the appropriate query string" do
        visit '/servers', :get, default_request_parameters

        redirect_params = Addressable::URI.parse(response.headers['Location']).query_values
        %w(ns ns.sreg sreg.nickname sreg.email claimed_id identity mode op_endpoint assoc_handle response_nonce signed).each do |k|
          redirect_params["openid.#{k}"].should_not be_nil
        end
      end
    end

    describe " with valid openid 2.0 parameters when authenticated", :given => 'an authenticated user' do
      it "should redirect to the acceptance page since the host isn't trusted yet" do
        visit '/servers', :get, default_request_parameters
        response.headers['Location'].should eql('http://example.org/users/quentin')
      end
    end

    describe "with valid openid 2.0 parameters when unauthorized" do
      it "should redirect to the acceptance page(and /login if needed)" do
        visits '/servers', :get, default_request_parameters
        response.should be_a_valid_merb_auth_form
      end
    end
  end
end


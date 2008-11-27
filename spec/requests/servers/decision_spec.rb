describe Servers, "#decision" do
  describe "cancel clicked", :given => 'an authenticated user requesting auth' do
    it "redirects to the cancel url" do
      response = request("/servers/decision", {'REQUEST_METHOD' => 'POST'})
      response.should redirect_to('http://consumerapp.com/')

      redirected_to = Addressable::URI.parse(response.headers['Location'])
      redirect_params = redirected_to.query_values
      redirect_params['openid.mode'].should == 'cancel'
      redirect_params['openid.ns'].should == 'http://specs.openid.net/auth/2.0'
    end
  end
  describe "agreement clicked", :given => 'an authenticated user requesting auth' do
    it "redirects to the consumer url" do
      response = request("/servers/decision?yes=yes", {'REQUEST_METHOD' => 'POST'})
      response.status.should == 302

      redirect_params = Addressable::URI.parse(response.headers['Location']).query_values
      %w(sreg.nickname sreg.email mode op_endpoint assoc_handle response_nonce signed).each do |k|
        redirect_params["openid.#{k}"].should_not be_nil
      end
    end
    it "should handle multiple identities better via oidreq.id_select"
  end
end

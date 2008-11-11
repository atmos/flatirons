require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Servers, "#decision" do
  describe "decision screens" do

    describe "cancel clicked", :given => 'an authenticated user requesting auth' do
      it "redirects to the cancel url" do
        response = request("/servers/decision", {'REQUEST_METHOD' => 'POST'})
        response.status.should == 302
        response.should have_xpath('//a[@href="http://consumerapp.com/?openid.mode=cancel"]')
      end
    end
    describe "agreement clicked", :given => 'an authenticated user requesting auth' do
      it "redirects to the cancel url" do
        response = request("/servers/decision?yes=yes", {'REQUEST_METHOD' => 'POST'})
        response.status.should == 302
        
        redirect_params = query_parse(Addressable::URI.parse(response.headers['Location']).query)
        %w(sreg.nickname sreg.email mode op_endpoint assoc_handle response_nonce signed).each do |k|
          redirect_params["openid.#{k}"].should_not be_nil
        end
      end
      it "should handle multiple identities better via oidreq.id_select"
    end
  end
end

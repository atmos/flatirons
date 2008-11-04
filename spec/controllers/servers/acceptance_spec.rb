require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Servers, "#acceptance" do
  before(:each) do
    @store = OpenID::Store::Filesystem.new(Merb.root / 'config' / 'openid-store-test')
    @server = OpenID::Server::Server.new(@store, '/servers')
  end

  describe "authenticated" do
    it "should prompt for login" do
      lambda { @response = dispatch_to(Servers, :acceptance, {}) }.should raise_error
    end
  end

  describe "unauthenticated" do
    before(:each) do
      @check_id_request = OpenID::Server::CheckIDRequest.new('http://localhost/users/atmos', 
                                                              'http://localhost', 
                                                              @server.op_endpoint, 
                                                              'http://localhost')

      @user = User.first(:login => 'atmoose')
      @response = dispatch_to(Servers, :acceptance, {}) do |controller|
        mock(controller.session).[](:user).times(any_times) { @user.id }
        mock(controller.session).[](:last_oidreq) { @check_id_request }
        # stub(controller.session).[](:authentication_strategies) { nil }
      end
    end
    it "should be successful" do
      @response.should be_successful
    end
    it "should redirect to the login page" do
      @response.should have_xpath("//form[@action='/servers/decision' and @method='post']")
    end
  end
end
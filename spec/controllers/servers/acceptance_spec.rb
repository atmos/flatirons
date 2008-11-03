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
      @response.should have_xpath("//form[@action='/servers/decision']")
    end
  end
  # describe "empty params" do
  #   it "should raise errors" do
  #     lambda { dispatch_to(Servers, :decision) }.should raise_error
  #   end
  # end
  # 
  # describe "decision screens" do
  #   before(:each) do
  #     @params = {"openid.mode"=>"checkid_setup", "openid.return_to" => 'http://localhost',
  #               'openid.identity' => 'http://localhost/users/atmos'}
  #     @check_id_request = OpenID::Server::CheckIDRequest.new('http://localhost/users/atmos', 
  #                                                             'http://localhost', 
  #                                                             @server.op_endpoint, 
  #                                                             'http://localhost')
  #     @message = OpenID::Message.new('http://specs.openid.net/auth/2.0')        
  #     @check_id_request.message = @message
  # 
  #     @check_id_response = OpenID::Server::OpenIDResponse.new(@check_id_request)
  #   end
  # 
  #   describe "cancel" do
  #     before(:each) do
  #       @response = dispatch_to(Servers, :decision, {:cancel => :cancel}) do |controller|
  #         mock(controller.session).[](:last_oidreq) { @check_id_request }
  #       end
  #     end
  #     it "should redirect the user" do
  #       @response.status.should == 302
  #     end
  #   end
  # 
  #   describe "agreement" do
  #     before(:each) do
  #       mock(OpenID::Store::Filesystem).new(Merb.root / 'config' / 'openid-store') { @store }
  #       mock(OpenID::Server::Server).new(@store, 'http://localhost/servers') { @server }
  #       
  #       mock(@check_id_request).answer(true, nil, 'http://localhost/users/atmos') { @check_id_response }
  #       
  #       @response = dispatch_to(Servers, :decision, {:yes => :yes}) do |controller|
  #         mock(controller.session).[](:last_oidreq) { @check_id_request }
  #       end
  #     end
  #     it "should be successful" do
  #       @response.status.should == 302
  #     end
  #     it "should render the good stuff" do
  #       @response.body.should match(%r!<a href="http://localhost\?.*?"!)
  #     end
  #   end
  # end
end
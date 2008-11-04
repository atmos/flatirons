require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Servers, "#decision" do
  before(:each) do
    @store = OpenID::Store::Filesystem.new(Merb.root / 'config' / 'openid-store-test')
    @server = OpenID::Server::Server.new(@store, '/servers')
  end

  describe "empty params" do
    it "should raise errors" do
      lambda { dispatch_to(Servers, :decision) }.should raise_error
    end
  end
  

  describe "decision screens" do
    before(:each) do
      @params = {"openid.mode"=>"checkid_setup", "openid.return_to" => 'http://goatse.cx',
                'openid.identity' => 'http://openid.goatse.cx/users/atmos'}
      @check_id_request = OpenID::Server::CheckIDRequest.new('http://openid.goatse.cx/users/atmos', 
                                                              'http://goatse.cx', 
                                                              @server.op_endpoint, 
                                                              'http://goatse.cx')
      @message = OpenID::Message.new('http://specs.openid.net/auth/2.0')        
      @check_id_request.message = @message

      @check_id_response = OpenID::Server::OpenIDResponse.new(@check_id_request)
    end

    describe "cancel" do
      before(:each) do
        @response = dispatch_to(Servers, :decision, {:cancel => :cancel}) do |controller|
          mock(controller.session).delete(:last_oidreq) { @check_id_request }
        end
      end
      it "should redirect the user" do
        @response.status.should == 302
      end
    end

    describe "agreement" do
      before(:each) do
        mock(OpenID::Store::Filesystem).new(Merb.root / 'config' / 'openid-store') { @store }
        mock(OpenID::Server::Server).new(@store, 'http://localhost/servers') { @server }
        
        mock(@check_id_request).answer(true, nil, 'http://openid.goatse.cx/users/atmos') { @check_id_response }
        
        @response = dispatch_to(Servers, :decision, {:yes => :yes}) do |controller|
          mock(controller.session).delete(:last_oidreq) { @check_id_request }
          %w(notice authentication_strategies return_to).each do |k|
            mock(controller.session).delete(k) { nil }
          end
        end
      end
      it "should be successful" do
        @response.status.should == 302
      end
      it "should render the good stuff" do
        @response.body.should match(%r!<a href="http://goatse.cx\?.*?"!)
      end
    end
  end
end
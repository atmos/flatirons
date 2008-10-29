require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Servers, "index action" do
  before(:each) do
    @store = OpenID::Store::Filesystem.new(Merb.root / 'config' / 'openid-store-test')
    @server = OpenID::Server::Server.new(@store, '/servers')

    mock(OpenID::Store::Filesystem).new(Merb.root / 'config' / 'openid-store') { @store }
    mock(OpenID::Server::Server).new(@store, '/servers') { @server }
  end

  describe "empty params" do
    it "should raise errors" do
      lambda { dispatch_to(Servers, :index) }.should raise_error
    end
  end

  describe "checkIDRequests" do
    before(:each) do
      @params = {"openid.mode"=>"checkid_setup", "openid.return_to" => 'http://goatse.cx',
                'openid.identity' => 'http://openid.goatse.cx/users/atmos'}
      @check_id_request = OpenID::Server::CheckIDRequest.new('http://openid.goatse.cx/users/atmos', 
                                                              'http://goatse.cx', 
                                                              @server.op_endpoint, 
                                                              'http://goatse.cx')
                                                              
      @check_id_response = mock(OpenID::Server::OpenIDResponse).new { @check_id_request }
      mock(@check_id_request).answer(true, nil, 'http://openid.goatse.cx/users/atmos') { @check_id_response }
      
      @decoder = OpenID::Server::Decoder.new(@server)
      # mock(@decoder).decode('') { @check_id_request }
      
      # mock(OpenID::Server::Decoder).new { @decoder }
      # mock(OpenID::Server::CheckIDRequest).new { @check_id_request }
      mock(@server).decode_request(hash_including(@params)) { @check_id_request }
    end
    describe "with openid params but unauthorized" do
      before(:each) do
        @response = dispatch_to(Servers, :index, @params) do |controller|
          mock(controller).authorized?(@params['openid.identity'], @params['openid.return_to']) { false }
        end
      end
      it "should return http success" do
        @response.status.should == 200
      end
      it "should display the decision form" do
        @response.body.should match(%r!action="/servers/decision">!)
      end
    end

    describe "with openid params and authorized" do
      before(:each) do
        @response = dispatch_to(Servers, :index, @params) do |controller|
          stub(controller).session { {:username => 'atmos'} }
          mock(controller).authorized?(@params['openid.identity'], @params['openid.return_to']) { true }
        end
      end
      it "should return http success" do
        @response.status.should == 302
      end
      it "should display the decision form" do
        @response.body.should match(%r!href="http://goatse.cx?.*"!)
      end
    end

    # describe "with openid params, unauthorized, but with an immediate flag present" do
    #   before(:each) do
    # 
    #     mock(@check_id_request).immediate { true }
    # 
    #     @response = dispatch_to(Servers, :index, @params) do |controller|
    #       stub(controller).session { {:username => 'atmos'} }
    #       mock(controller).authorized?(@params['openid.identity'], @params['openid.return_to']) { false }
    #     end
    #   end
    #   it "should return http success" do
    #     @response.status.should == 302
    #   end
    #   it "should display the decision form" do
    #     @response.body.should match(%r!href="http://goatse.cx?.*"!)
    #   end
    # end
  end
end
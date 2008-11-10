require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

shared_examples_for "redirecting to the acceptance page" do
  it "should return http success" do
    @response.status.should == 302
  end
  it "should display the decision form" do
    @response.should have_xpath("//a[@href='/servers/acceptance']")
  end
end

shared_examples_for "successful authorization and redirection to the consumer" do
  it "should return http redirect" do
    @response.status.should == 302
  end
  it "should redirect back to the site requesting auth" do
    @response.body.should match(%r!href="http://localhost?.*"!)
  end

  it "should set the appropriate headers on redirect"
end

describe Servers, "#index" do
  before(:each) do
    @store = OpenID::Store::Filesystem.new(Merb.root / 'config' / 'openid-store-test')
    @server = OpenID::Server::Server.new(@store, '/servers')

    mock(OpenID::Store::Filesystem).new(Merb.root / 'config' / 'openid-store') { @store }
    mock(OpenID::Server::Server).new(@store, 'http://localhost/servers') { @server }
  end

  describe "empty params" do
    it "should raise errors" do
      lambda { dispatch_to(Servers, :index) }.should raise_error
    end
  end

  describe "checkIDRequests" do
    before(:each) do
      @params = {"openid.mode"=>"checkid_setup", "openid.return_to" => 'http://localhost',
                'openid.identity' => 'http://localhost/users/atmos',
                'openid.claimed_id' => 'http://localhost/users/atmos'}
      @check_id_request = @server.decode_request(@params)

      mock(@server).decode_request(anything) { @check_id_request }
    end
    
    describe "with openid params but unauthorized," do
      before(:each) do
        @response = dispatch_to(Servers, :index, @params) do |controller|
          mock(controller).authorized?(@params['openid.identity'], @params['openid.return_to']) { false }
        end
      end
      it_should_behave_like "redirecting to the acceptance page"
    end

    describe "with openid params and authorized," do
      before(:each) do
        @message = OpenID::Message.new('http://specs.openid.net/auth/2.0')        
        @check_id_request.message = @message

        @check_id_response = OpenID::Server::OpenIDResponse.new(@check_id_request)

        mock(OpenID::Server::OpenIDResponse).new(@check_id_request) { @check_id_response }
                
        @response = dispatch_to(Servers, :index, @params) do |controller|
          stub(controller).session { {:username => 'atmos'} }
          mock(controller).authorized?(@params['openid.identity'], @params['openid.return_to']) { true }
        end
      end
      it_should_behave_like "successful authorization and redirection to the consumer"

      describe " redirect query parameters" do
        before(:each) do
          @redirect_params = query_parse(Addressable::URI.parse(@response.headers['Location']).query)
        end

        %w(ns ns.sreg sreg.nickname sreg.email claimed_id identity mode op_endpoint assoc_handle response_nonce signed).each do |k|
          it "should include openid.#{k}" do
            @redirect_params["openid.#{k}"].should_not be_nil
          end
        end
      end
    end

    describe "with openid params, unauthorized, immediate flag," do
      before(:each) do
        @message = OpenID::Message.new('http://specs.openid.net/auth/2.0')        
        @check_id_request.message = @message

        @check_id_response = OpenID::Server::OpenIDResponse.new(@check_id_request)
      end
      
      describe "set to true" do
        before(:each) do
          mock(@check_id_request).answer(false, '/servers') { @check_id_response }
          mock(@check_id_request).immediate { true }

          @response = dispatch_to(Servers, :index, @params) do |controller|
            stub(controller).session { {:username => 'atmos'} }
            mock(controller).authorized?(@params['openid.identity'], @params['openid.return_to']) { false }
          end
        end
        it_should_behave_like "successful authorization and redirection to the consumer"
      end

      describe "set to false" do
        before(:each) do
          mock(@check_id_request).immediate { false }

          @response = dispatch_to(Servers, :index, @params) do |controller|
            stub(controller).session { {:username => 'atmos'} }
            mock(controller).authorized?(@params['openid.identity'], @params['openid.return_to']) { false }
          end
        end
        it_should_behave_like "redirecting to the acceptance page"
      end
    end
  end
end
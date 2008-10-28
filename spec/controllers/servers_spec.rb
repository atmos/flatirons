require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Servers, "index action" do
  before(:each) do
    store = OpenID::Store::Filesystem.new(Merb.root / 'config' / 'openid-store-test')
    server = OpenID::Server::Server.new(store, '/servers')
    
    mock(OpenID::Store::Filesystem).new(Merb.root / 'config' / 'openid-store') { store }
    mock(OpenID::Server::Server).new(store, '/servers') { server }
  end

  describe "empty params" do
    it "should raise errors" do
      lambda { dispatch_to(Servers, :index) }.should raise_error
    end
  end


  describe "with openid params unauthenticated" do
    before(:each) do
      params = {"openid.mode"=>"checkid_setup", "openid.return_to" => 'http://goatse.cx',
                'openid.identity' => 'http://openid.goatse.xc/user/atmos'}
      @response = dispatch_to(Servers, :index, params)
    end
    it "should return http success" do
      @response.status.should == 200
    end
    it "should display the decision form" do
      @response.body.should match(%r!action="/servers/decision">!)
    end
  end
  
  describe "with openid params authenticated" do
    before(:each) do
      params = {"openid.mode"=>"checkid_setup", "openid.return_to" => 'http://goatse.cx',
                'openid.identity' => 'http://openid.goatse.xc/user/atmos'}
      @response = dispatch_to(Servers, :index, params) do |controller|
        stub(controller).session { {:username => 'atmos'} }
      end
    end
    it "should return http success" do
      @response.status.should == 200
    end
    it "should display the decision form" do
      @response.body.should match(%r!action="/servers/decision">!)
    end
  end
  
end
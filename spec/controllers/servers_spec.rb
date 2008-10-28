require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Servers, "index action" do
  before(:each) do
    store = OpenID::Store::Filesystem.new(Merb.root / 'config' / 'openid-store-test')
    server = OpenID::Server::Server.new(store, '/servers')
    
    mock(OpenID::Store::Filesystem).new(Merb.root / 'config' / 'openid-store') { store }
    mock(OpenID::Server::Server).new(store, '/servers') { server }
  end
  before(:each) do
    @response = dispatch_to(Servers, :index)
  end
  it "should return http success" do
    @response.status.should == 200
  end
end
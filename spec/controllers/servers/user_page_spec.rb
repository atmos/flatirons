require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')
shared_examples_for "redirecting to the decision page" do
  it "should return http success" do
    @response.status.should == 200
  end
  it "should display the decision form" do
    @response.body.should match(%r!action="/servers/decision">!)
  end
end
shared_examples_for "successful authorization and redirection to the consumer" do
  it "should return http redirect" do
    @response.status.should == 302
  end
  it "should redirect back to the site requesting auth" do
    @response.body.should match(%r!href="http://goatse.cx?.*"!)
  end
  it "should set the appropriate headers on redirect"
end

describe Servers, "user_page action" do
  before(:each) do
    @store = OpenID::Store::Filesystem.new(Merb.root / 'config' / 'openid-store-test')
    @server = OpenID::Server::Server.new(@store, '/servers')

    # mock(OpenID::Store::Filesystem).new(Merb.root / 'config' / 'openid-store') { @store }
    # mock(OpenID::Server::Server).new(@store, '/servers') { @server }
  end

  describe "empty params" do
    it "should raise errors" do
      lambda { dispatch_to(Servers, :user_page) }.should raise_error
    end
  end
end
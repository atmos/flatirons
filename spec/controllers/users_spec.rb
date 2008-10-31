require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Users, "index action" do
  before(:each) do
    dispatch_to(Users, :index)
  end
end

describe Users, "show action" do
  before(:each) do
    User.all.destroy!
    User.create(:login => 'atmos', :password => 'zomgwtfbbq', :password_confirmation => 'zomgwtfbbq')    
  end
  describe "accepting xrds+xml" do
    before(:each) do
      @response = dispatch_to(Users, :show, {:id => User.first.id}, {:http_accept => 'application/xrds+xml'})
    end
    it "should return http success" do
      @response.should be_successful
    end
    it "match this response body" do
      @response.body.should match(%r!<URI>http://localhost/servers</URI>!)
    end
  end
  
  describe "accepting text/html" do
    before(:each) do
      @response = dispatch_to(Users, :show, {:id => User.first.id})
    end
    it "should return http success" do
      @response.should be_successful
    end
    it "have the openid provider in the response" do
      @response.body.should have_xpath("//link[@rel='openid.server' and @href='http://localhost/users/#{User.first.id}']")
    end
  end
end
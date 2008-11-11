require File.join( File.dirname(__FILE__), '..', "spec_helper" )
 
describe User do
  describe "#create with valid params" do
    it "should be valid" do
      user = User.first_or_create({ :login => 'atmos', :email => 'joe@atmoose.org'}, 
                    {:identity_url => 'http://foo.myopenid.com/atmos', :password => 'foo', :password_confirmation => 'foo'})
      user.should be_valid
    end
  end
end
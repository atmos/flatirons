describe User do
  after(:each) { User.all.destroy! }
  describe "#create with valid params" do
    it "should be valid" do
      user = User.first_or_create({ :login => 'atmos', :email => 'joe@atmoose.org'}, 
                    {:password => 'foo', :password_confirmation => 'foo'})
      user.should be_valid
    end
  end
end
describe User do
  describe "#create with valid params" do
    it "should be valid" do
      user = User.create(:login => 'arthur', :email => 'arthur@example.org')
      user.save
      user.should be_valid
      user.should_not be_registered
    end
  end
end

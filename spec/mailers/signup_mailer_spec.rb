describe "A New User signing up for an account" do
  before :each do
    clear_mail_deliveries
  end
  
  describe "with valid info" do
    it "redirects arthur to login and provides a registration url via email" do
      response = request("/users", :method => 'post', 
                         :params => {:email => 'arthur@example.com', :login => 'arthur'})
      response.should redirect_to('/login')

      last_delivered_mail.text.should match(%r!http://example.org/arthur!)
      registration_url = "/users/signup/\\?token=#{User.first(:login => 'arthur').registration_token}"
      last_delivered_mail.text.should match(%r!#{registration_url}!)
    end
  end
  describe "with invalid info" do
    it "displays the signup form again" do
      response = request("/users", :method => 'post', 
                         :params => {:email => 'arthur.com', :login => 'arthur'})
      response.should be_successful
      response.should have_selector("form[action='/users'][method='post']")
      response.should have_selector("input#login[type='text'][name='login']")
      response.should have_selector("input#email[type='text'][name='email']")

      last_delivered_mail.should be_nil
    end
  end
end

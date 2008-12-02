describe SignupMailer, "#notify_on_event email template" do
  before :each do
    clear_mail_deliveries
  end
  
  describe "arthur signing up for an account with valid info" do
    it "welcomes arthur to our sight and provides a registration url" do
      response = request("/users", :method => 'post', 
                         :params => {:email => 'arthur@example.com', :login => 'arthur'})
      response.should redirect_to('/login')

      last_delivered_mail.text.should match(%r!http://example.org/arthur!)
      registration_url = "/users/signup/#{User.first(:login => 'arthur').registration_token}"
      last_delivered_mail.text.should match(%r!#{registration_url}!)
    end
  end
  describe "arthur signing up for an account with invalid info" do
    it "welcomes arthur to our sight and provides a registration url" do
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

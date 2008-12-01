describe SignupMailer, "#notify_on_event email template" do
  before :each do
    clear_mail_deliveries
  end
  
  describe "signup quentin up", :given => 'an authenticated user' do
    it "includes welcome phrase in email text" do
      response = request("/users/signup")
      response.should redirect_to('/login')

      last_delivered_mail.text.should match(%r!http://example.org/quentin!)
      last_delivered_mail.text.should match(%r!/lolerskates!)
    end
  end
end

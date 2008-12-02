describe "Signup up for an account" do
  it "display a form requesting your email address" do
    response = request("/users/new")
    response.should be_successful
    response.should have_selector("form[action='/users'][method='post']")
    response.should have_selector("input#login[type='text'][name='login']")
    response.should have_selector("input#email[type='text'][name='email']")
  end
end

describe "Deleting Quentin's account" do
  before(:each) { setup_user }
  it "delete quentin's account successfully" do
    response = request("/users/quentin", :method => 'delete')
    response.should redirect_to(url(:new_user))
  end
end

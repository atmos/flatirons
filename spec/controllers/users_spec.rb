require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Users, "index action" do
  before(:each) do
    dispatch_to(Users, :index)
  end
end

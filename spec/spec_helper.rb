require "rubygems"

# Add the local gems dir if found within the app root; any dependencies loaded
# hereafter will try to load from the local gems before loading system gems.
if (local_gem_dir = File.join(File.dirname(__FILE__), '..', 'gems')) && $BUNDLE.nil?
  $BUNDLE = true; Gem.clear_paths; Gem.path.unshift(local_gem_dir)
end

require "merb-core"
require "spec" # Satisfies Autotest and anyone else not using the Rake tasks
require 'pp'

# this loads all plugins required in your init file so don't add them
# here again, Merb will do it for you
Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')

# transaction specs
module Flatirons
  class ExampleGroup < Merb::Test::ExampleGroup
    before(:each) do
      @transaction = DataMapper::Transaction.new(repository(:default))
      @transaction.begin
      repository(:default).adapter.push_transaction(@transaction)
    end
    after(:each) do
      repository(:default).adapter.pop_transaction
      @transaction.rollback
    end
    Spec::Example::ExampleGroupFactory.default(self)
  end
end

module FlatironsLoginForm
  class FlatironsFormDisplay
    include Merb::Test::ViewHelper
    def matches?(target)
      target.status.should == 401
      login_param = Merb::Plugins.config[:"merb-auth"][:login_param]
      target.should have_selector("div.content form[action='/login'][method='POST']")
      target.should have_selector("div.content form input[type='hidden'][name='_method'][value='PUT']")
      target.should have_selector("div.content form input##{login_param}[name='#{login_param}'][type='text']")
      target.should have_selector("div.content form input#password[name='password'][type='password']")
    end
  end

  def be_a_valid_merb_auth_form
    FlatironsFormDisplay.new
  end
end

# setup helpers for rspec
Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
  config.include(FlatironsLoginForm)
  config.mock_with(:rr)

  def setup_user
    @user =  User.create(:login => 'quentin', :email => 'quentin@example.com', :password => 'foo', :password_confirmation => 'foo')
  end

  def login_user
    response = request "/login", :method => "PUT", :params => { :login => 'quentin', :password => 'foo' }
    response.should redirect_to("/")
  end

  def default_request_parameters
    {
      "openid.ns"         => "http://specs.openid.net/auth/2.0",
      "openid.mode"       => "checkid_setup", 
      "openid.return_to"  => "http://consumerapp.com/",
      "openid.identity"   => "http://example.org/users/quentin",
      "openid.claimed_id" => "http://example.org/users/quentin"
    }
  end
end

given "an authenticated user" do
  setup_user
  login_user
end

given "an authenticated user requesting auth" do
  setup_user
  request("/servers", :params => default_request_parameters)
  login_user
end

given 'an returning user with trusted hosts in their session' do
  setup_user
  request("/servers", :params => default_request_parameters)
  login_user
  response = request("/servers/decision?yes=yes", {'REQUEST_METHOD' => 'POST'})
  response.status.should == 302
end

require "rubygems"

# Add the local gems dir if found within the app root; any dependencies loaded
# hereafter will try to load from the local gems before loading system gems.
if (local_gem_dir = File.join(File.dirname(__FILE__), '..', 'gems')) && $BUNDLE.nil?
  $BUNDLE = true; Gem.clear_paths; Gem.path.unshift(local_gem_dir)
end

require "merb-core"
require "spec" # Satisfies Autotest and anyone else not using the Rake tasks
require 'pp'
require 'ruby-debug'
require 'webrat/merb'
require 'webrat/selenium'
# this loads all plugins required in your init file so don't add them
# here again, Merb will do it for you
Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')

# transaction specs
module Flatirons
#  class ExampleGroup < Merb::Test::ExampleGroup
#    before(:each) do
#      @transaction = DataMapper::Transaction.new(repository(:default))
#      @transaction.begin
#      repository(:default).adapter.push_transaction(@transaction)
#    end
#    after(:each) do
#      repository(:default).adapter.pop_transaction
#      @transaction.rollback
#    end
#    Spec::Example::ExampleGroupFactory.default(self)
#  end

  module MailControllerTestHelper
    # Helper to clear mail deliveries.
    def clear_mail_deliveries
      Merb::Mailer.deliveries.clear
    end
    # Helper to access last delivered mail.
    # In test mode merb-mailer puts email to
    # collection accessible as Merb::Mailer.deliveries.
    def last_delivered_mail
      Merb::Mailer.deliveries.last
    end
  end
end

module FlatironsLoginForm
  class FlatironsFormDisplay
    include Merb::Test::ViewHelper
    def matches?(target)
#      target.status.should == 401
      login_param = Merb::Plugins.config[:"merb-auth"][:login_param]
      target.should have_selector("div.content form[action='/login'][method='post']")
      target.should have_selector("div.content form input[type='hidden'][name='_method'][value='PUT']")
      target.should have_selector("div.content form input##{login_param}[name='#{login_param}'][type='text']")
      target.should have_selector("div.content form input#password[name='password'][type='password']")
    end
  end

  def be_a_valid_merb_auth_form
    FlatironsFormDisplay.new
  end
end

class Merb::Mailer
  self.delivery_method = :test_send
end

if ENV['SELENIUM'].nil?
  Webrat.configuration.mode = :merb
else 
  Webrat.configuration.mode = :selenium
  Webrat.configuration.application_framework = :merb
  Webrat.configuration.application_environment = :test
  Webrat.configuration.application_port = 4000
end

# setup helpers for rspec
Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
  config.include(Webrat::Methods)
  config.include(Webrat::Selenium::Methods)
  if ENV['SELENIUM'].nil?
    config.include(Webrat::Matchers)
  else
    config.include(Webrat::Selenium::Matchers)
  end
  config.include(FlatironsLoginForm)
  config.include(FlatironsLoginForm)
  config.include(Flatirons::MailControllerTestHelper)
  config.mock_with(:rr)

  config.after(:each) do
    User.all.destroy!
  end

  def setup_user
    @user =  User.create(:login => 'quentin', :email => 'quentin@example.com', :password => 'foo', :password_confirmation => 'foo')
  end

  def login_user
    visit '/'
    fill_in 'login', :with => 'quentin'
    fill_in 'password', :with => 'foo'
    click_button 'Log in'
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
  visit '/servers', :get, default_request_parameters
  login_user
end

given 'an returning user with trusted hosts in their session' do
  setup_user
  visit '/servers', :get, default_request_parameters
  login_user

  visit '/servers/decision', :post, {'yes' => 'yes'}
  response.status.should == 302
end

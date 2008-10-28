# Go to http://wiki.merbivore.com/pages/init-rb
gem 'ruby-openid', '2.1.2'
require 'config/dependencies.rb'

use_orm :datamapper
use_test :rspec
use_template_engine :erb
 
Merb::Config.use do |c|
  c[:use_mutex] = false
  c[:session_store] = 'cookie'  # can also be 'memory', 'memcache', 'container', 'datamapper
  
  # cookie session store configuration
  c[:session_secret_key]  = 'fbe44747c953159bc4ad423415f45504c4822cc6'  # required for cookie session store
  # c[:session_id_key] = '_session_id' # cookie session id key, defaults to "_session_id"
end
 
Merb::BootLoader.before_app_loads do
  require "openid"
  require "openid/consumer/discovery"
  require 'openid/extensions/sreg'
  require 'openid/extensions/pape'
  require 'openid/store/filesystem'
  # This will get executed after dependencies have been loaded but before your app's classes have loaded.
end
 
Merb::BootLoader.after_app_loads do
  # This will get executed after your app's classes have been loaded.
end

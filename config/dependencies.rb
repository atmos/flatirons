add_source "http://gems.rubyforge.org/"

add_gem 'rspec', '=1.1.11'
add_gem 'rake'
add_gem 'rcov'
add_gem 'mongrel'
add_gem 'hoe'
add_gem 'rr'
add_dependency 'extlib', '=0.9.9', :require => 'extlib'
add_gem 'do_sqlite3', '=0.9.9'
add_gem 'ruby-debug', '=0.10.3'

merb_gems_version = "=1.0.4"
dm_gems_version   = "=0.9.8"

add_dependency 'dm-core', dm_gems_version
add_dependency 'dm-validations', dm_gems_version, :require => 'dm-validations'

add_dependency 'merb-core', merb_gems_version, :require => 'merb-core'
add_dependency 'merb-gen', merb_gems_version, :require => 'merb-gen'
add_dependency 'merb-param-protection', merb_gems_version, :require => 'merb-param-protection'
add_dependency 'merb-haml', merb_gems_version, :require => 'merb-haml'
add_dependency 'merb-auth-core', merb_gems_version, :require => 'merb-auth-core'
add_dependency 'merb-auth-more', merb_gems_version, :require => 'merb-auth-more'
add_dependency 'merb-cache', merb_gems_version, :require => 'merb-cache'
add_dependency 'merb-helpers', merb_gems_version, :require => 'merb-helpers'
add_dependency 'merb-assets', merb_gems_version, :require => 'merb-assets'
add_dependency 'merb-slices', merb_gems_version, :require => 'merb-slices'
add_dependency 'merb-auth-slice-password', merb_gems_version, :require => 'merb-auth-slice-password'
add_dependency 'merb-action-args', merb_gems_version, :require => 'merb-action-args'
add_dependency 'merb-mailer', merb_gems_version, :require => 'merb-mailer'
add_dependency 'merb_datamapper', dm_gems_version

add_dependency 'ruby-openid', '=2.1.2'
add_dependency 'nokogiri', '>=1.0.6'
add_dependency 'webrat', '=0.3.2'

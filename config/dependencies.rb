# dependencies are generated using a strict version, don't forget to edit the dependency versions when upgrading.
merb_gems_version = "~>1.0.9"
dm_gems_version   = "~>0.9.10"

# For more information about each component, please read http://wiki.merbivore.com/faqs/merb_components
dependency "dm-core", dm_gems_version         
dependency "dm-validations", dm_gems_version  

dependency "merb-core", merb_gems_version
dependency "merb-gen", merb_gems_version
dependency "merb-action-args", merb_gems_version
dependency "merb-assets", merb_gems_version  
dependency "merb-cache", merb_gems_version   
dependency "merb-helpers", merb_gems_version 
dependency "merb-haml", merb_gems_version 
dependency "merb-mailer", merb_gems_version  
dependency "merb-slices", merb_gems_version  
dependency "merb-auth-core", merb_gems_version
dependency "merb-auth-more", merb_gems_version
dependency "merb-auth-slice-password", merb_gems_version
dependency "merb-param-protection", merb_gems_version
dependency "merb-exceptions", merb_gems_version
dependency 'merb_datamapper', merb_gems_version

dependency "ruby-openid", '=2.1.2', :require_as => 'openid'

dependency 'nokogiri', '>=1.0.6',   :require_as => nil
dependency 'webrat', '=0.3.2',      :require_as => nil
dependency 'rr',                    :require_as => nil
dependency 'rcov',                  :require_as => nil
dependency 'mongrel',               :require_as => nil
dependency 'ruby-debug', '=0.10.3', :require_as => nil


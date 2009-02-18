Merb.logger.info("Compiling routes...")
Merb::Router.prepare do
  # RESTful routes
  # resources :posts
  resources :users, :collection => {:signup => :get}

  # Adds the required routes for merb-auth using the password slice
  slice(:merb_auth_slice_password, :name_prefix => nil, :path_prefix => "")

  match("/servers").to(:controller => 'servers').name('servers')
  match("/servers/xrds").to(:controller => 'servers', :action => :idp_page).name('xrds')
  match("/servers/acceptance").to(:controller => 'servers', :action => 'acceptance').name('acceptance')
  match("/servers/decision").to(:controller => 'servers', :action => 'decision').name('server_decision')

  # Change this for your home page to be available at /
  match('/').to(:controller => 'servers', :action => 'landing')
end

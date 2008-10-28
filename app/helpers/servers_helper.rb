module Merb
  module ServersHelper
    def server
      if @server.nil?
        server_url = url(:servers)
        dir = Merb.root / 'config' / 'openid-store'
        store = OpenID::Store::Filesystem.new(dir)
        @server = OpenID::Server::Server.new(store, server_url)
      end
      return @server
    end

    def show_decision_page(oidreq)
      session[:last_oidreq] = oidreq
      @oidreq = oidreq

      # if message
      #   flash[:notice] = message
      # end
      partial 'decide'
    end
    
    def authorized?(identity_url, trust_root)
      return (session[:username] and (identity_url == url_for_user) and approved(trust_root))
    end
    
    def approved(trust_root)
      return false if session[:approvals].nil?
      return session[:approvals].member?(trust_root)
    end
    
    def url_for_user
      url(:users, {:id => session[:username]})
    end
  end
end # Merb
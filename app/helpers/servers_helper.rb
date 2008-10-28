module Merb
  module ServersHelper
    def server
      if @server.nil?
        server_url = "/servers"
        dir = Merb.root / 'config' / 'openid-store'
        store = OpenID::Store::Filesystem.new(dir)
        @server = OpenID::Server::Server.new(store, server_url)
      end
      return @server
    end
    def show_decision_page(oidreg)
      session[:last_oidreq] = oidreq
      @oidreq = oidreq

      # if message
      #   flash[:notice] = message
      # end
      partial 'decide'
    end
  end
end # Merb
module Merb
  module ServersHelper
    def server
      if @server.nil?
        server_url = absolute_url(:servers)
        dir = Merb.root / 'config' / 'openid-store'
        store = OpenID::Store::Filesystem.new(dir)
        @server = OpenID::Server::Server.new(store, server_url)
      end
      return @server
    end
    
    def authorized?(identity_url, trust_root)
      return (session[:user] and (identity_url == identity_url_for_user) and approved(trust_root))
    end
    
    def approved(trust_root)
      return false if session[:approvals].nil?
      return session[:approvals].member?(trust_root)
    end
    
    def identity_url_for_user
      absolute_url(:user, {:id => session.user.login})
    end

    def add_sreg(oidreq, oidresp)
      return if session.user.nil? #FAIL
      sreg_data = {
        'nickname' => session.user.login,
        'email'    => session.user.email
      }
      sregresp = OpenID::SReg::Response.new(sreg_data)
      oidresp.add_extension(sregresp)
    end
    
    def render_response(oidresp)
      if oidresp.needs_signing
        signed_response = server.signatory.sign(oidresp)
      end
      web_response = server.encode_response(oidresp)

      case web_response.code
      when 200
        web_response.body

      when 302
        %w(notice authentication_strategies return_to).each do |session_key|
          session.delete(session_key)
        end
        Merb.logger.info! session.inspect
        redirect web_response.headers['location']
      end
    end
  end
end

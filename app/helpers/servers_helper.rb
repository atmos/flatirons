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

    def show_decision_page(oidreq, message="Do you trust this site with your identity?")
      session[:last_oidreq] = oidreq
      @oidreq = oidreq

      if message
        session[:notice] = message
      end
      partial 'decide'
    end
    
    def authorized?(identity_url, trust_root)
      return (session[:user] and (identity_url == url_for_user) and approved(trust_root))
    end
    
    def approved(trust_root)
      return false if session[:approvals].nil?
      return session[:approvals].member?(trust_root)
    end
    
    def url_for_user
      url(:users, {:id => session.user.login})
    end
    
    def add_sreg(oidreq, oidresp)
      user = User.first(:identity_url => oidreq.identity)
      return if user.nil? #FAIL
      sreg_data = {
        'nickname' => user.login,
        'email'    => user.email
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
      else
        web_response.body
      end
    end

    def idp_xrds
      types = [
               OpenID::OPENID_IDP_2_0_TYPE,
              ]

      headers['content-type'] = 'application/xrds+xml'
      partial :yadis, :types => types
    end
  end
end # Merb
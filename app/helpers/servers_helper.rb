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

    def show_decision_page(oidreq, message="Do you trust this site with your identity?")
      session[:last_oidreq] = oidreq
      @oidreq = oidreq

      if message
        session[:notice] = message
      end
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
    
    def add_sreg(oidreq, oidresp, identity)
      # check for Simple Registration arguments and respond
      sregreq = OpenID::SReg::Request.from_openid_request(oidreq)

      return if sregreq.nil?
      # In a real application, this data would be user-specific,
      # and the user should be asked for permission to release
      # it.
      sreg_data = {
        'nickname' => User.first(:login => identity),
        'fullname' => 'Mayor McCheese',
        'email' => session.user.email
      }

      sregresp = OpenID::SReg::Response.extract_response(sregreq, sreg_data)
      oidresp.add_extension(sregresp)
    end
    
    def add_pape(oidreq, oidresp)
      papereq = OpenID::PAPE::Request.from_openid_request(oidreq)
      return if papereq.nil?
      paperesp = OpenID::PAPE::Response.new
      paperesp.nist_auth_level = 0 # we don't even do auth at all!
      oidresp.add_extension(paperesp)
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
        redirect web_response.headers['location']
      else
        web_response.body
      end
    end
    def user_xrds
      types = [
               OpenID::OPENID_2_0_TYPE,
               OpenID::OPENID_1_0_TYPE,
               OpenID::SREG_URI,
              ]

      headers['content-type'] = 'application/xrds+xml'
      render_xrds(types)
    end

    def idp_xrds
      types = [
               OpenID::OPENID_IDP_2_0_TYPE,
              ]

      headers['content-type'] = 'application/xrds+xml'
      render_xrds(types)
    end

    def render_xrds(types)
      type_str = ""

      types.each { |uri|
        type_str += "<Type>#{uri}</Type>\n      "
      }

      yadis = <<EOS
<?xml version="1.0" encoding="UTF-8"?>
<xrds:XRDS
    xmlns:xrds="xri://$xrds"
    xmlns="xri://$xrd*($v*2.0)">
  <XRD>
    <Service priority="0">
      #{type_str}
      <URI>#{absolute_url(:servers)}</URI>
    </Service>
  </XRD>
</xrds:XRDS>
EOS

      yadis
    end
  end
end # Merb
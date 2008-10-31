require 'pp'

class Servers < Application
  include OpenID::Server
  # ...and remember, everything returned from an action
  # goes to the client...
  def index
    oidreq = server.decode_request(params)
    
    # no openid.mode was given, FIXME I've yet to see this case hit
    return("This is an OpenID server endpoint.") unless oidreq
    
    oidresp = nil

    if oidreq.kind_of?(CheckIDRequest)
      identity = oidreq.identity
      
      if oidresp
        nil
      elsif authorized?(identity, oidreq.trust_root)
        oidresp = oidreq.answer(true, nil, identity)
        # 
        # # add the sreg response if requested
        # add_sreg(oidreq, oidresp)
        # # ditto pape
        # add_pape(oidreq, oidresp)
      elsif oidreq.immediate
        server_url = url(:servers)
        oidresp = oidreq.answer(false, server_url)
      else
        return show_decision_page(oidreq)
      end
    else
      oidresp = server.handle_request(oidreq)
    end

    render_response(oidresp)
  end

  def decision
    oidreq = session[:last_oidreq]

    session[:last_oidreq] = nil

    if params.has_key?(:cancel)
      Merb::Logger.info("Cancelling OpenID Authentication")
      return(redirect(oidreq.cancel_url))
    else      
      identity = oidreq.identity
      oidresp = oidreq.answer(true, nil, identity)
      add_sreg(oidreq, oidresp)
      return render_response(oidresp)
      # identity =~ /node\/(.+)$/
      # openid_node = Chef::OpenIDRegistration.load($1)
      # unless openid_node.validated
      #   raise Unauthorized, "This nodes registration has not been validated"
      # end
      # if openid_node.password == encrypt_password(openid_node.salt, params[:password])     
      #   if session[:approvals]
      #     session[:approvals] << oidreq.trust_root
      #   else
      #     session[:approvals] = [oidreq.trust_root]
      #   end
      #   oidresp = oidreq.answer(true, nil, identity)
      #   return self.render_response(oidresp)
      # else
      #   raise Unauthorized, "Invalid credentials"
      # end
    end
    
  end
end

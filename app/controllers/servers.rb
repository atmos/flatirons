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

end

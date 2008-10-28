class Servers < Application
  include OpenID::Server
  # ...and remember, everything returned from an action
  # goes to the client...
  def index
    begin
      oidreq = server.decode_request(params)
    rescue ProtocolError => e
      # invalid openid request, so just display a page with an error message
      raise InternalServerError.new(e.to_s)
    end
    
    # no openid.mode was given, FIXME I've yet to see this case hit
    return("This is an OpenID server endpoint.") unless oidreq
    
    oidresp = nil

    if oidreq.kind_of?(CheckIDRequest)
      identity = oidreq.identity

      if oidreq.id_select
        if oidreq.immediate
          oidresp = oidreq.answer(false)
        elsif session[:username].nil?
          # The user hasn't logged in.
          return show_decision_page(oidreq)
        else
          # Else, set the identity to the one the user is using.
          identity = url_for_user
        end
      end
      
      if oidresp
        nil
      elsif authorized?(identity, oidreq.trust_root)
        oidresp = oidreq.answer(true, nil, identity)

        # add the sreg response if requested
        add_simple_registration(oidreq, oidresp)
        # ditto pape
        add_pape(oidreq, oidresp)

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

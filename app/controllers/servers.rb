class Servers < Application
  before :ensure_authenticated, :only => [:acceptance]
  include OpenID::Server
  # ...and remember, everything returned from an action
  # goes to the client...
  def index
    oidreq = session[:last_oidreq].nil? ? server.decode_request(params) : session[:last_oidreq]
    
    # no openid.mode was given, FIXME I've yet to see this case hit
    return("This is an OpenID server endpoint.") unless oidreq
    
    oidresp = nil
    
    if oidreq.kind_of?(CheckIDRequest)
      identity = oidreq.identity
      
      if oidresp
        nil
      elsif authorized?(identity, oidreq.trust_root)
        oidresp = oidreq.answer(true, nil, identity)
        add_sreg(oidreq, oidresp)

      elsif oidreq.immediate
        oidresp = oidreq.answer(false, url(:servers))
      else
        session[:last_oidreq] = oidreq
        return(redirect(url(:acceptance)))
      end
    else
      oidresp = server.handle_request(oidreq)
    end

    render_response(oidresp)
  end

  def decision
    oidreq = session.delete(:last_oidreq)

    if params[:yes].nil?
      Merb.logger.info("Cancelling OpenID Authentication")
      return(redirect(oidreq.cancel_url))
    else
      id_to_send = params[:id_to_send]

      identity = oidreq.identity
      if oidreq.id_select
        if id_to_send and id_to_send != ""
          session[:username] = id_to_send
          session[:approvals] = []
          identity = url(:user, {:id => id_to_send})
        else
          msg = "You must enter a username to in order to send " +
            "an identifier to the Relying Party."
          return show_decision_page(oidreq, msg)
        end
      end
      if session[:approvals]
        session[:approvals] << oidreq.trust_root
        session[:approvals].uniq!
      else
        session[:approvals] = [oidreq.trust_root]
      end

      
      oidresp = oidreq.answer(true, nil, identity)
      add_sreg(oidreq, oidresp)
    end
    render_response(oidresp)
  end
  
  def users_page(id)
    provides :xrds, :html
    # Yadis content-negotiation: we want to return the xrds if asked for.
    accept = request.env['HTTP_ACCEPT']

    # This is not technically correct, and should eventually be updated
    # to do real Accept header parsing and logic.  Though I expect it will work
    # 99% of the time.
    if accept and accept.include?('application/xrds+xml')
      return user_xrds
    end

    # content negotiation failed, so just render the user page
    # Also add the Yadis location header, so that they don't have
    headers['X-XRDS-Location'] = absolute_url(:user_xrds, {:id => params[:id]})
    render :layout => false
  end
  
  def acceptance(message="Do you trust this site with your identity?")
    @oidreq = session[:last_oidreq]

    if message
      session[:notice] = message
    end
    render
  end
end

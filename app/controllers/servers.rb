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
        # add_sreg(oidreq, oidresp, identity)
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
      Merb.logger.info("Cancelling OpenID Authentication")
      return(redirect(oidreq.cancel_url))
    else      
      identity = oidreq.identity
      oidresp = oidreq.answer(true, nil, identity)
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
  
  def users_page(id)
    @user = User.first(:login => id)
    # Yadis content-negotiation: we want to return the xrds if asked for.
    accept = request.env['HTTP_ACCEPT']

    # This is not technically correct, and should eventually be updated
    # to do real Accept header parsing and logic.  Though I expect it will work
    # 99% of the time.
    if accept and accept.include?('application/xrds+xml')
      return user_xrds
    end

    # content negotiation failed, so just render the user page
    xrds_url = absolute_url(:xrds_user, {:id => @user.id})
    identity_page = <<EOS
<html><head>
<meta http-equiv="X-XRDS-Location" content="#{xrds_url}" />
<link rel="openid.server" href="#{absolute_url(:user, {:id => @user.id})}" />
</head><body><p>OpenID identity page for #{@user.login}</p>
</body></html>
EOS

    # Also add the Yadis location header, so that they don't have
    # to parse the html unless absolutely necessary.
    headers['X-XRDS-Location'] = xrds_url
    identity_page
  end
end

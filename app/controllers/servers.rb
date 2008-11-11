class Servers < Application
  before :ensure_authenticated, :only => [:acceptance]
  include OpenID::Server

  def index
    begin
      oidreq = server.decode_request(params)
    rescue OpenID::Server::ProtocolError => e
      Merb.logger.info e.message
      oidreq = session[:last_oidreq]
      return render
    end
    
    oidresp = nil
    
    if oidreq.kind_of?(CheckIDRequest)
      identity = oidreq.identity

      if authorized?(identity, oidreq.trust_root)
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
    oidreq = session[:last_oidreq]

    if params[:yes].nil?
      Merb.logger.info("Cancelling OpenID Authentication")
      return(redirect(oidreq.cancel_url))
    else
      id_to_send = session.user.login

      identity = oidreq.identity

      # if oidreq.id_select
      #   if id_to_send and id_to_send != ""
      #     session[:username] = id_to_send
      #     session[:approvals] = []
      #     identity = url(:user, {:id => id_to_send})
      #   else
      #     msg = "You must enter a username to in order to send " +
      #       "an identifier to the Relying Party."
      #     return show_decision_page(oidreq, msg)
      #   end
      # end
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
  
  def idp_page(id = nil)
    provides :xrds
    @types = [
             OpenID::OPENID_2_0_TYPE,
             OpenID::OPENID_1_0_TYPE,
             OpenID::SREG_URI,
            ]
    render :layout => false
  end
  
  def acceptance(message="Do you trust this site with your identity?")
    @oidreq = session[:last_oidreq]

    return redirect(url(:user, {:id => session[:username]})) if @oidreq.nil?

    if message
      session[:notice] = message
    end
    render
  end
end

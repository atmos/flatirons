class Users < Application

  # ...and remember, everything returned from an action
  # goes to the client...
  def index
    render
  end
  
  def show(id)
    @user = User.get(id)
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

class Users < Application
  def show(email)
    provides :xrds, :html

    @user = User.first(:email => email)
    raise NotFound unless @user
    @types = [ OpenID::OPENID_2_0_TYPE, OpenID::SREG_URI ]
    headers['X-XRDS-Location'] = absolute_url(:user_xrds, {:email => email})
    render :layout => false
  end
end

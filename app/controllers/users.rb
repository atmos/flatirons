class Users < Application
  def show(id)
    provides :xrds, :html

    @user = User.first(:login => id)
    raise NotFound unless @user
    @types = [ OpenID::OPENID_2_0_TYPE, OpenID::SREG_URI ]
    headers['X-XRDS-Location'] = absolute_url(:user_xrds, {:id => @user.login})
    render :layout => false
  end
end

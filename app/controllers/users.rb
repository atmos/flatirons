class Users < Application
  def show(id)
    provides :xrds, :html

    @types = [ OpenID::OPENID_2_0_TYPE, OpenID::OPENID_1_0_TYPE, OpenID::SREG_URI ]
    headers['X-XRDS-Location'] = absolute_url(:user_xrds, {:id => params[:id]})
    render :layout => false
  end
end

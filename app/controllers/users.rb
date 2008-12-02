class Users < Application
  def show(id)
    provides :xrds, :html

    @user = User.first(:login => id)
    raise NotFound unless @user
    @types = [ OpenID::OPENID_2_0_TYPE, OpenID::SREG_URI ]
    headers['X-XRDS-Location'] = absolute_url(:user, {:id => @user.login, :format => :xrds})
    render :layout => false
  end

  def new
    render
  end

  def create(login, email)
    @user = User.create(:login => login, :email => email)
    if @user.valid?
      send_mail(SignupMailer, :notify_on_event, {
        :from => 'root@example.com',
        :to => @user.email,
        :subject => "Welcome to the Flatirons OpenID Provider"
      })
      redirect url(:login)
    else
      Merb.logger.info! @user.errors.inspect
      render :new
    end
  end

  def update(id, user)
    raise
  end

  def destroy(id)
    @user = User.first(:login => id)
    @user.destroy
    redirect(url(:new_user))
  end
end

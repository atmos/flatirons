class Users < Application
  before :ensure_authenticated, :exclude => [:show, :new, :create, :signup]

  def show(id)
    provides :xrds, :html

    @user = User.first(:login => id)
    raise NotFound unless @user
    @types = [ OpenID::OPENID_2_0_TYPE, OpenID::SREG_URI ]
    headers['X-XRDS-Location'] = absolute_url(:user, {:id => @user.login, :format => :xrds})
    render :layout => false
  end

  def new
    @user = User.new
    render
  end

  def edit
    render
  end

  def create(login, email)
    @user = User.create(:login => login, :email => email)
    if @user.valid?
      Merb.logger.info @user.inspect
      send_mail(SignupMailer, :notify_on_event, {
        :from => 'root@example.com',
        :to => @user.email,
        :subject => "Welcome to the Flatirons OpenID Provider"
      })
      redirect url(:login)
    else
      render :new
    end
  end

  def update(id, user)
    @user = User.first(:login => id)
    redirect '/'
  end

  def signup(token)
    @user = User.first(:registration_token => token)
    session[:user] = @user.id
    render :edit
  end

  def destroy(id)
    @user = User.first(:login => id)
    @user.destroy
    redirect(url(:new_user))
  end
end

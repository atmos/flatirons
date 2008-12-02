class SignupMailer < Merb::MailController
  def notify_on_event
    @host = 'http://example.org'
    @user = User.first(:login => params[:login])
    render_mail
  end
end

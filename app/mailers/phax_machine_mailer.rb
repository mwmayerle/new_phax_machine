class PhaxMachineMailer < Devise::Mailer   
  helper :application #
  include Devise::Controllers::UrlHelpers 
  default template_path: 'devise/mailer' 

  def welcome_invite(record, token, opts={})
  	headers["Custom-header"] = "Bar"
  	opts[:from] = 'matt@phaxio.com'
    @token = token
    devise_mail(record, :welcome_invite, opts)
  end

  def fax_sent(sender, client)
  	@sender = sender
  	@client = client
  	devise_mail(
  		current_user,
  		to: @sender.email_address,
      subject: 'you done got a fax',
    )
  end

  def fax_received
  end
end
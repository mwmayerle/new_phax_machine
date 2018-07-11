class PhaxMachineMailer < Devise::Mailer   
  helper :application #
  include Devise::Controllers::UrlHelpers 
  default template_path: 'devise/mailer' 

  def client_manager_welcome_invite(record, token, opts = {})
  	opts[:from] = ENV.fetch('ADMIN_EMAIL')
  	opts[:subject] = "You've been invited to manage #{record.client.client_label}."
    @token = token
    devise_mail(record, :client_manager_welcome_invite, opts)
  end

  def user_welcome_invite(record, token, opts = {})
  	opts[:from] = record.client_manager.email
  	opts[:subject] = "You've been invited to Phax Machine"
    @token = token
    devise_mail(record, :user_welcome_invite, opts)
  end

end
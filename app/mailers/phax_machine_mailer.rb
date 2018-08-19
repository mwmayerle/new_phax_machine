class PhaxMachineMailer < Devise::Mailer   
  helper :application #
  include Devise::Controllers::UrlHelpers 
  default template_path: 'devise/mailer' 

  def manager_welcome_invite(record, token, opts = {})
  	opts[:from] = ENV.fetch('ADMIN_EMAIL')
  	opts[:subject] = "You've been invited to manage #{record.organization.label}."
    @token = token
    devise_mail(record, :manager_welcome_invite, opts)
  end

  def user_welcome_invite(record, token, opts = {})
  	record.manager ? opts[:from] = record.manager.email : opts[:from] = 'phax_machine@phax_machine.com'
  	opts[:subject] = "You've been invited to Phax Machine"
    @token = token
    devise_mail(record, :user_welcome_invite, opts)
  end

  def admin_welcome_invite(record, token, opts = {})
  	opts[:subject] = "You've been invited to be the administer of Phax Machine"
    @token = token
    devise_mail(record, :admin_welcome_invite, opts)
  end

end
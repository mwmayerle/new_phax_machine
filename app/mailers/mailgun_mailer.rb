class MailgunMailer < ApplicationMailer
	default from: ENV["FROM_EMAIL"]

	def fax_email(email_addresses, email_subject, fax, fax_file_name = '', fax_file_contents = '')
  	@email_addresses = email_addresses
  	@fax = fax
  	@email_subject = email_subject
  	@logo_link = LogoLink.first ? LogoLink.first.logo_url : 'https://assets.voyant.com/logos/voyant-logo.png'
  	mail.attachments[fax_file_name] = fax_file_contents if fax_file_name != ''
  	mail(to: @email_addresses, subject: @email_subject)
  end

  def failed_email_to_fax_email(sender, sent_fax_object)
		@sender = sender
		@logo_link = LogoLink.first ? LogoLink.first.logo_url : 'https://assets.voyant.com/logos/voyant-logo.png'
		@sent_fax_object = sent_fax_object
  	mail(to: @sender, subject: "There was a problem delivering your fax")
  end
end

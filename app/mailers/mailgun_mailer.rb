class MailgunMailer < ApplicationMailer
	default from: ENV["FROM_EMAIL"]
	ALTERNATE_LOGO_PATH = 'https://ui-ex.com/images/transparent-rectangle-4.png'.freeze

	def fax_email(email_addresses, email_subject, fax, fax_file_name = '', fax_file_contents = '')
  	@email_addresses = email_addresses
  	@fax = fax
  	@email_subject = email_subject
  	@logo_link = LogoLink.first ? LogoLink.first.logo_url : ALTERNATE_LOGO_PATH
  	if fax_file_name != '' && fax_file_contents != ''
  		mail.attachments[fax_file_name] = fax_file_contents
  	end
  	mail(to: @email_addresses, subject: @email_subject)
  end

  def failed_email_to_fax_email(sender, sent_fax_object)
		@sender = sender
		@logo_link = LogoLink.first ? LogoLink.first.logo_url : ALTERNATE_LOGO_PATH
		@sent_fax_object = sent_fax_object
  	mail(to: @sender, subject: "There was a problem delivering your fax")
  end
end

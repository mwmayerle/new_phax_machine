class MailgunMailer < ApplicationMailer
	default from: ENV["SMTP_FROM"]

	def fax_email(email_addresses, email_subject, fax, fax_file_name = '', fax_file_contents = '')
  	@email_addresses = email_addresses
  	@fax = fax
  	@email_subject = email_subject
  	mail.attachments[fax_file_name] = fax_file_contents if fax_file_name != ''
  	mail(
  		to: @email_addresses,
  		subject: @email_subject,
  	)
  end
end

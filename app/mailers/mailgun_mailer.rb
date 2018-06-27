class MailgunMailer < ApplicationMailer
	default from: ENV["SMTP_FROM"]

	def fax_email(email_addresses, email_subject, fax, attachments = {})
  	@email_addresses = email_addresses
  	@fax = fax
  	@email_subject = email_subject
  	@attachments = attachments
  	mail(
  		to: @email_addresses,
  		subject: @email_subject,
  		attachments: @attachments
  	)
  end
end

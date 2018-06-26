class MailgunMailer < ApplicationMailer
	default from: ENV["SMTP_FROM"]

	def fax_email(email_addresses, email_subject, fax)
  	@email_addresses = email_addresses
  	@fax = fax
  	@email_subject = email_subject
  	mail(
  		to: @email_addresses.email_address,
  		subject: @email_subject,
  	)
  end
end

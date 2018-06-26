class MailgunMailer < ApplicationMailer
	default from: ENV["SMTP_FROM"]

	def fax_email(fax_sender, email_subject, fax)
  	@fax_sender = fax_sender
  	@client = fax_sender.client
  	@fax = fax
  	@email_subject = email_subject
  	mail(
  		to: @fax_sender.email_address,
  		subject: @email_subject,
  	)
  end
end
